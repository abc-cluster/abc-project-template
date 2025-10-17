#!/usr/bin/env python3
"""
Compare Nextflow Experiments
Generates comparison reports, metrics diffs, and parameter analysis
"""

import argparse
import json
import sqlite3
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Any
import yaml


SCRIPT_DIR = Path(__file__).parent
BASE_DIR = SCRIPT_DIR.parent
DB_PATH = BASE_DIR / ".registry" / "experiments.db"
COMPARISONS_DIR = BASE_DIR / "comparisons"


class ExperimentComparator:
    """Compare multiple experiments"""
    
    def __init__(self, db_path: Path = DB_PATH):
        self.db_path = db_path
        self.comparisons_dir = COMPARISONS_DIR
        self.comparisons_dir.mkdir(exist_ok=True)
    
    def get_experiment_details(self, exp_id: str) -> Optional[Dict[str, Any]]:
        """Fetch experiment details from database"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT * FROM experiments WHERE id = ?
        """, (exp_id,))
        
        row = cursor.fetchone()
        conn.close()
        
        if not row:
            return None
        
        return dict(row)
    
    def load_experiment_files(self, exp_id: str) -> Dict[str, Any]:
        """Load experiment configuration files"""
        # Find experiment directory
        for exp_type in ["development", "production", "planning"]:
            exp_dir = BASE_DIR / "experiments" / exp_type / "runs" / exp_id
            if exp_dir.exists():
                break
        else:
            return {}
        
        data = {}
        
        # Load params
        params_file = exp_dir / "params.yaml"
        if params_file.exists():
            with open(params_file) as f:
                data["params"] = yaml.safe_load(f)
        
        # Load metadata
        metadata_file = exp_dir / "metadata.yaml"
        if metadata_file.exists():
            with open(metadata_file) as f:
                data["metadata"] = yaml.safe_load(f)
        
        # Load execution
        execution_file = exp_dir / "execution.yaml"
        if execution_file.exists():
            with open(execution_file) as f:
                data["execution"] = yaml.safe_load(f)
        
        # Load Tower metadata if available
        tower_file = exp_dir / "tower-metadata.json"
        if tower_file.exists():
            with open(tower_file) as f:
                data["tower"] = json.load(f)
        
        # Load Tower summary
        summary_file = exp_dir / "tower-summary.json"
        if summary_file.exists():
            with open(summary_file) as f:
                data["tower_summary"] = json.load(f)
        
        return data
    
    def compare_params(self, experiments: List[Dict[str, Any]]) -> str:
        """Generate parameter comparison markdown"""
        output = ["## Parameter Comparison\n"]
        
        # Collect all parameter keys
        all_keys = set()
        for exp in experiments:
            if "params" in exp["files"]:
                all_keys.update(exp["files"]["params"].keys())
        
        if not all_keys:
            return "## Parameter Comparison\n\nNo parameters found.\n"
        
        # Create comparison table
        output.append("| Parameter | " + " | ".join([exp["db"]["id"][:20] for exp in experiments]) + " |")
        output.append("|-----------|" + "|".join(["-----" for _ in experiments]) + "|")
        
        for key in sorted(all_keys):
            row = [key]
            for exp in experiments:
                params = exp["files"].get("params", {})
                value = params.get(key, "N/A")
                row.append(str(value)[:30])
            output.append("| " + " | ".join(row) + " |")
        
        output.append("")
        return "\n".join(output)
    
    def compare_metrics(self, experiments: List[Dict[str, Any]]) -> str:
        """Generate metrics comparison markdown"""
        output = ["## Metrics Comparison\n"]
        
        # Create metrics table
        headers = ["Metric"] + [exp["db"]["id"][:20] for exp in experiments]
        output.append("| " + " | ".join(headers) + " |")
        output.append("|" + "|".join(["-----" for _ in range(len(headers))]) + "|")
        
        # Status
        row = ["Status"] + [exp["db"]["status"] for exp in experiments]
        output.append("| " + " | ".join(row) + " |")
        
        # Duration
        row = ["Duration"]
        for exp in experiments:
            tower_summary = exp["files"].get("tower_summary", {})
            duration = tower_summary.get("duration", "N/A")
            row.append(str(duration))
        output.append("| " + " | ".join(row) + " |")
        
        # Task stats
        for metric in ["succeeded", "failed", "cached", "total_tasks"]:
            row = [metric.title()]
            for exp in experiments:
                tower_summary = exp["files"].get("tower_summary", {})
                value = tower_summary.get(metric, "N/A")
                row.append(str(value))
            output.append("| " + " | ".join(row) + " |")
        
        # Exit status
        row = ["Exit Status"]
        for exp in experiments:
            tower_summary = exp["files"].get("tower_summary", {})
            exit_status = tower_summary.get("exit_status", "N/A")
            row.append(str(exit_status))
        output.append("| " + " | ".join(row) + " |")
        
        output.append("")
        return "\n".join(output)
    
    def compare_timeline(self, experiments: List[Dict[str, Any]]) -> str:
        """Generate timeline comparison markdown"""
        output = ["## Timeline Comparison\n"]
        
        headers = ["Event"] + [exp["db"]["id"][:20] for exp in experiments]
        output.append("| " + " | ".join(headers) + " |")
        output.append("|" + "|".join(["-----" for _ in range(len(headers))]) + "|")
        
        # Created
        row = ["Created"] + [exp["db"]["created_at"] for exp in experiments]
        output.append("| " + " | ".join(row) + " |")
        
        # Started
        row = ["Started"]
        for exp in experiments:
            tower_summary = exp["files"].get("tower_summary", {})
            started = tower_summary.get("started", "N/A")
            row.append(str(started))
        output.append("| " + " | ".join(row) + " |")
        
        # Completed
        row = ["Completed"]
        for exp in experiments:
            tower_summary = exp["files"].get("tower_summary", {})
            completed = tower_summary.get("completed", "N/A")
            row.append(str(completed))
        output.append("| " + " | ".join(row) + " |")
        
        output.append("")
        return "\n".join(output)
    
    def compare_resources(self, experiments: List[Dict[str, Any]]) -> str:
        """Generate resource comparison markdown"""
        output = ["## Resource Configuration\n"]
        
        headers = ["Resource"] + [exp["db"]["id"][:20] for exp in experiments]
        output.append("| " + " | ".join(headers) + " |")
        output.append("|" + "|".join(["-----" for _ in range(len(headers))]) + "|")
        
        # Compute environment
        row = ["Compute Env"]
        for exp in experiments:
            tower_summary = exp["files"].get("tower_summary", {})
            compute = tower_summary.get("compute_env", "N/A")
            row.append(str(compute))
        output.append("| " + " | ".join(row) + " |")
        
        # Nextflow version
        row = ["Nextflow Ver"]
        for exp in experiments:
            tower_summary = exp["files"].get("tower_summary", {})
            nf_ver = tower_summary.get("nextflow_version", "N/A")
            row.append(str(nf_ver))
        output.append("| " + " | ".join(row) + " |")
        
        # Container engine
        row = ["Container"]
        for exp in experiments:
            tower_summary = exp["files"].get("tower_summary", {})
            container = tower_summary.get("container_engine", "N/A")
            row.append(str(container))
        output.append("| " + " | ".join(row) + " |")
        
        output.append("")
        return "\n".join(output)
    
    def generate_comparison_report(
        self, 
        exp_ids: List[str],
        output_name: Optional[str] = None
    ) -> str:
        """Generate comprehensive comparison report"""
        
        # Load all experiments
        experiments = []
        for exp_id in exp_ids:
            db_data = self.get_experiment_details(exp_id)
            if not db_data:
                print(f"Warning: Experiment {exp_id} not found", file=sys.stderr)
                continue
            
            file_data = self.load_experiment_files(exp_id)
            experiments.append({
                "db": db_data,
                "files": file_data
            })
        
        if len(experiments) < 2:
            print("Error: Need at least 2 experiments to compare", file=sys.stderr)
            return ""
        
        # Generate report
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        if not output_name:
            output_name = f"comparison_{timestamp}"
        
        output_file = self.comparisons_dir / f"{output_name}.md"
        
        report = []
        report.append(f"# Experiment Comparison: {output_name}")
        report.append(f"\n**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        report.append(f"**Experiments Compared:** {len(experiments)}\n")
        
        # Overview
        report.append("## Experiment Overview\n")
        for i, exp in enumerate(experiments, 1):
            db = exp["db"]
            report.append(f"### Experiment {i}: {db['id']}\n")
            report.append(f"- **Type:** {db['type']}")
            report.append(f"- **Status:** {db['status']}")
            report.append(f"- **Purpose:** {db['purpose']}")
            report.append(f"- **Created:** {db['created_at']}")
            if db['tower_run_id']:
                report.append(f"- **Tower Run:** {db['tower_run_id']}")
            report.append("")
        
        # Comparisons
        report.append(self.compare_timeline(experiments))
        report.append(self.compare_metrics(experiments))
        report.append(self.compare_params(experiments))
        report.append(self.compare_resources(experiments))
        
        # Differences section
        report.append("## Key Differences\n")
        report.append("### Status Comparison")
        statuses = [exp["db"]["status"] for exp in experiments]
        if len(set(statuses)) > 1:
            report.append(f"- Status varies: {', '.join(set(statuses))}")
        else:
            report.append(f"- All experiments have status: {statuses[0]}")
        report.append("")
        
        # Write report
        with open(output_file, "w") as f:
            f.write("\n".join(report))
        
        # Also save JSON
        json_file = self.comparisons_dir / f"{output_name}.json"
        comparison_data = {
            "timestamp": timestamp,
            "experiments": [
                {
                    "id": exp["db"]["id"],
                    "type": exp["db"]["type"],
                    "status": exp["db"]["status"],
                    "created_at": exp["db"]["created_at"],
                    "params": exp["files"].get("params", {}),
                    "metrics": exp["files"].get("tower_summary", {})
                }
                for exp in experiments
            ]
        }
        with open(json_file, "w") as f:
            json.dump(comparison_data, f, indent=2)
        
        return str(output_file)
    
    def list_comparisons(self) -> List[Dict[str, Any]]:
        """List all saved comparisons"""
        comparisons = []
        for md_file in self.comparisons_dir.glob("*.md"):
            stat = md_file.stat()
            comparisons.append({
                "name": md_file.stem,
                "path": str(md_file),
                "created": datetime.fromtimestamp(stat.st_ctime).strftime("%Y-%m-%d %H:%M:%S"),
                "size": stat.st_size
            })
        return sorted(comparisons, key=lambda x: x["created"], reverse=True)


def main():
    parser = argparse.ArgumentParser(
        description="Compare Nextflow experiments",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    subparsers = parser.add_subparsers(dest="command", required=True)
    
    # Compare command
    compare_parser = subparsers.add_parser("compare", help="Compare experiments")
    compare_parser.add_argument(
        "experiments",
        nargs="+",
        help="Experiment IDs to compare"
    )
    compare_parser.add_argument(
        "-o", "--output",
        help="Output report name (default: auto-generated)"
    )
    
    # List command
    list_parser = subparsers.add_parser("list", help="List saved comparisons")
    
    # View command
    view_parser = subparsers.add_parser("view", help="View comparison report")
    view_parser.add_argument("name", help="Comparison name")
    
    args = parser.parse_args()
    
    comparator = ExperimentComparator()
    
    if args.command == "compare":
        print(f"🔄 Comparing {len(args.experiments)} experiments...")
        report_path = comparator.generate_comparison_report(
            args.experiments,
            args.output
        )
        if report_path:
            print(f"✅ Comparison report generated: {report_path}")
            print(f"📊 View with: cat {report_path}")
        else:
            sys.exit(1)
    
    elif args.command == "list":
        comparisons = comparator.list_comparisons()
        if not comparisons:
            print("No comparisons found")
        else:
            print(f"\n📋 Found {len(comparisons)} comparison(s):\n")
            for comp in comparisons:
                print(f"  {comp['name']}")
                print(f"    Created: {comp['created']}")
                print(f"    Path: {comp['path']}")
                print()
    
    elif args.command == "view":
        report_file = COMPARISONS_DIR / f"{args.name}.md"
        if not report_file.exists():
            print(f"❌ Comparison '{args.name}' not found", file=sys.stderr)
            sys.exit(1)
        
        with open(report_file) as f:
            print(f.read())


if __name__ == "__main__":
    main()
