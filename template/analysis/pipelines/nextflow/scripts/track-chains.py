#!/usr/bin/env python3
"""
Track Experiment Resume Chains
Visualize experiment lineage and manage resume history
"""

import argparse
import json
import sqlite3
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Any

SCRIPT_DIR = Path(__file__).parent
BASE_DIR = SCRIPT_DIR.parent
DB_PATH = BASE_DIR / ".registry" / "experiments.db"
CHAINS_DIR = BASE_DIR / "chains"


class ChainTracker:
    """Track and visualize experiment resume chains"""
    
    def __init__(self, db_path: Path = DB_PATH):
        self.db_path = db_path
        self.chains_dir = CHAINS_DIR
        self.chains_dir.mkdir(exist_ok=True)
    
    def create_chain(self, original_exp_id: str, resumed_exp_id: str, run_number: int = 2):
        """Create a new resume chain"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Check if chain exists for original experiment
        cursor.execute("""
            SELECT chain_id FROM experiments WHERE id = ?
        """, (original_exp_id,))
        result = cursor.fetchone()
        
        if result and result[0]:
            # Chain exists, add to it
            chain_id = result[0]
        else:
            # Create new chain
            chain_id = f"chain_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            # Update original experiment
            cursor.execute("""
                UPDATE experiments 
                SET chain_id = ?, run_number = 1 
                WHERE id = ?
            """, (chain_id, original_exp_id))
        
        # Update resumed experiment
        cursor.execute("""
            UPDATE experiments 
            SET chain_id = ?, run_number = ?, parent_experiment_id = ? 
            WHERE id = ?
        """, (chain_id, run_number, original_exp_id, resumed_exp_id))
        
        conn.commit()
        conn.close()
        
        print(f"✅ Chain updated: {chain_id}")
        print(f"   Original: {original_exp_id} (run 1)")
        print(f"   Resumed:  {resumed_exp_id} (run {run_number})")
    
    def get_chain(self, chain_id: str) -> List[Dict[str, Any]]:
        """Get all experiments in a chain"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT * FROM experiments 
            WHERE chain_id = ?
            ORDER BY run_number
        """, (chain_id,))
        
        experiments = [dict(row) for row in cursor.fetchall()]
        conn.close()
        
        return experiments
    
    def get_experiment_chain(self, exp_id: str) -> Optional[List[Dict[str, Any]]]:
        """Get the chain containing a specific experiment"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        # Get chain_id for this experiment
        cursor.execute("""
            SELECT chain_id FROM experiments WHERE id = ?
        """, (exp_id,))
        result = cursor.fetchone()
        
        if not result or not result['chain_id']:
            conn.close()
            return None
        
        chain_id = result['chain_id']
        
        # Get all experiments in chain
        cursor.execute("""
            SELECT * FROM experiments 
            WHERE chain_id = ?
            ORDER BY run_number
        """, (chain_id,))
        
        experiments = [dict(row) for row in cursor.fetchall()]
        conn.close()
        
        return experiments
    
    def list_all_chains(self) -> List[Dict[str, Any]]:
        """List all chains"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT 
                chain_id,
                COUNT(*) as experiment_count,
                MIN(created_at) as first_run,
                MAX(created_at) as last_run,
                GROUP_CONCAT(status) as statuses
            FROM experiments
            WHERE chain_id IS NOT NULL
            GROUP BY chain_id
            ORDER BY last_run DESC
        """)
        
        chains = [dict(row) for row in cursor.fetchall()]
        conn.close()
        
        return chains
    
    def generate_chain_diagram(self, chain_id: str, output_format: str = "dot") -> str:
        """Generate chain visualization in Graphviz DOT format"""
        experiments = self.get_chain(chain_id)
        
        if not experiments:
            return ""
        
        # Generate DOT file
        dot_lines = [
            "digraph ExperimentChain {",
            "    rankdir=TB;",
            "    node [shape=box, style=rounded];",
            ""
        ]
        
        # Define nodes
        for exp in experiments:
            status_color = {
                "planned": "lightgray",
                "running": "yellow",
                "completed": "lightgreen",
                "failed": "lightcoral",
                "archived": "gray"
            }.get(exp['status'], "white")
            
            label = f"{exp['id'][:20]}\\nRun {exp['run_number']}\\n{exp['status']}"
            dot_lines.append(
                f'    "{exp["id"]}" [label="{label}", fillcolor="{status_color}", style="filled,rounded"];'
            )
        
        dot_lines.append("")
        
        # Define edges
        for i in range(len(experiments) - 1):
            dot_lines.append(
                f'    "{experiments[i]["id"]}" -> "{experiments[i+1]["id"]}" [label="resume"];'
            )
        
        dot_lines.append("}")
        
        dot_content = "\n".join(dot_lines)
        
        # Save DOT file
        dot_file = self.chains_dir / f"{chain_id}.dot"
        with open(dot_file, "w") as f:
            f.write(dot_content)
        
        # Try to generate PNG if graphviz is available
        png_file = self.chains_dir / f"{chain_id}.png"
        try:
            import subprocess
            subprocess.run(
                ["dot", "-Tpng", str(dot_file), "-o", str(png_file)],
                check=True,
                capture_output=True
            )
            print(f"📊 Generated diagram: {png_file}")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print(f"ℹ️  DOT file created: {dot_file}")
            print(f"   Install graphviz to generate PNG: brew install graphviz")
        
        return str(dot_file)
    
    def generate_chain_report(self, chain_id: str) -> str:
        """Generate detailed chain report"""
        experiments = self.get_chain(chain_id)
        
        if not experiments:
            return ""
        
        report = []
        report.append(f"# Resume Chain Report: {chain_id}\n")
        report.append(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        report.append(f"**Total Runs:** {len(experiments)}\n")
        
        # Overview
        report.append("## Chain Overview\n")
        report.append("| Run | Experiment ID | Status | Created | Duration |")
        report.append("|-----|---------------|--------|---------|----------|")
        
        for exp in experiments:
            run_num = exp['run_number'] or "?"
            exp_id = exp['id'][:30]
            status = exp['status']
            created = exp['created_at']
            duration = "N/A"  # TODO: calculate from Tower data
            report.append(f"| {run_num} | {exp_id} | {status} | {created} | {duration} |")
        
        report.append("")
        
        # Detailed sections
        report.append("## Detailed Run Information\n")
        for exp in experiments:
            report.append(f"### Run {exp['run_number']}: {exp['id']}\n")
            report.append(f"- **Status:** {exp['status']}")
            report.append(f"- **Created:** {exp['created_at']}")
            report.append(f"- **Updated:** {exp['updated_at']}")
            report.append(f"- **Purpose:** {exp['purpose']}")
            if exp['tower_run_id']:
                report.append(f"- **Tower Run:** {exp['tower_run_id']}")
            if exp['git_commit']:
                report.append(f"- **Git Commit:** {exp['git_commit'][:8]}")
            if exp['notes']:
                report.append(f"- **Notes:** {exp['notes']}")
            report.append("")
        
        # Summary
        report.append("## Chain Summary\n")
        statuses = [exp['status'] for exp in experiments]
        report.append(f"- **Total Runs:** {len(experiments)}")
        report.append(f"- **Completed:** {statuses.count('completed')}")
        report.append(f"- **Failed:** {statuses.count('failed')}")
        report.append(f"- **Running:** {statuses.count('running')}")
        report.append(f"- **First Run:** {experiments[0]['created_at']}")
        report.append(f"- **Last Run:** {experiments[-1]['created_at']}")
        report.append("")
        
        # Save report
        report_file = self.chains_dir / f"{chain_id}_report.md"
        with open(report_file, "w") as f:
            f.write("\n".join(report))
        
        return str(report_file)
    
    def analyze_chain(self, chain_id: str) -> Dict[str, Any]:
        """Analyze chain performance and patterns"""
        experiments = self.get_chain(chain_id)
        
        if not experiments:
            return {}
        
        analysis = {
            "chain_id": chain_id,
            "total_runs": len(experiments),
            "status_distribution": {},
            "first_run": experiments[0]['created_at'],
            "last_run": experiments[-1]['created_at'],
            "experiments": []
        }
        
        # Count statuses
        for exp in experiments:
            status = exp['status']
            analysis['status_distribution'][status] = analysis['status_distribution'].get(status, 0) + 1
        
        # Experiment details
        for exp in experiments:
            analysis['experiments'].append({
                "id": exp['id'],
                "run_number": exp['run_number'],
                "status": exp['status'],
                "created_at": exp['created_at'],
                "git_commit": exp['git_commit'],
                "tower_run_id": exp['tower_run_id']
            })
        
        return analysis


def main():
    parser = argparse.ArgumentParser(
        description="Track experiment resume chains",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    subparsers = parser.add_subparsers(dest="command", required=True)
    
    # Create chain
    create_parser = subparsers.add_parser("create", help="Create/update resume chain")
    create_parser.add_argument("original", help="Original experiment ID")
    create_parser.add_argument("resumed", help="Resumed experiment ID")
    create_parser.add_argument("--run-number", type=int, default=2, help="Run number")
    
    # Show chain
    show_parser = subparsers.add_parser("show", help="Show experiment's chain")
    show_parser.add_argument("experiment_id", help="Experiment ID")
    
    # List chains
    list_parser = subparsers.add_parser("list", help="List all chains")
    
    # Visualize chain
    viz_parser = subparsers.add_parser("visualize", help="Generate chain diagram")
    viz_parser.add_argument("chain_id", help="Chain ID")
    
    # Report
    report_parser = subparsers.add_parser("report", help="Generate chain report")
    report_parser.add_argument("chain_id", help="Chain ID")
    
    # Analyze
    analyze_parser = subparsers.add_parser("analyze", help="Analyze chain")
    analyze_parser.add_argument("chain_id", help="Chain ID")
    
    args = parser.parse_args()
    
    tracker = ChainTracker()
    
    if args.command == "create":
        tracker.create_chain(args.original, args.resumed, args.run_number)
    
    elif args.command == "show":
        chain = tracker.get_experiment_chain(args.experiment_id)
        if not chain:
            print(f"No chain found for experiment: {args.experiment_id}")
            sys.exit(1)
        
        print(f"\n🔗 Chain: {chain[0]['chain_id']}\n")
        print(f"Total runs: {len(chain)}\n")
        for exp in chain:
            status_emoji = {
                "completed": "✅",
                "failed": "❌",
                "running": "🔄",
                "planned": "📋",
                "archived": "📦"
            }.get(exp['status'], "❓")
            print(f"  Run {exp['run_number']}: {exp['id']} {status_emoji} {exp['status']}")
            print(f"           Created: {exp['created_at']}")
            if exp['purpose']:
                print(f"           Purpose: {exp['purpose']}")
            print()
    
    elif args.command == "list":
        chains = tracker.list_all_chains()
        if not chains:
            print("No chains found")
        else:
            print(f"\n🔗 Found {len(chains)} chain(s):\n")
            for chain in chains:
                print(f"  {chain['chain_id']}")
                print(f"    Experiments: {chain['experiment_count']}")
                print(f"    First run: {chain['first_run']}")
                print(f"    Last run: {chain['last_run']}")
                print()
    
    elif args.command == "visualize":
        print(f"📊 Generating diagram for chain: {args.chain_id}")
        dot_file = tracker.generate_chain_diagram(args.chain_id)
        if dot_file:
            print(f"✅ Diagram generated: {dot_file}")
    
    elif args.command == "report":
        print(f"📝 Generating report for chain: {args.chain_id}")
        report_file = tracker.generate_chain_report(args.chain_id)
        if report_file:
            print(f"✅ Report generated: {report_file}")
    
    elif args.command == "analyze":
        analysis = tracker.analyze_chain(args.chain_id)
        if analysis:
            print(json.dumps(analysis, indent=2))
        else:
            print(f"Chain not found: {args.chain_id}")
            sys.exit(1)


if __name__ == "__main__":
    main()
