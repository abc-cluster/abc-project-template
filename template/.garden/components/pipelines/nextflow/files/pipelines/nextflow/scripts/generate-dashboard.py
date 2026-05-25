#!/usr/bin/env python3
"""
Generate Investigation Dashboard
Creates markdown reports and optionally Quarto dashboards
"""

import argparse
import json
import sqlite3
from datetime import datetime
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
BASE_DIR = SCRIPT_DIR.parent
DB_PATH = BASE_DIR / ".registry" / "investigations.db"
DOCS_DIR = BASE_DIR / "docs"


class DashboardGenerator:
    """Generate investigation dashboards and reports"""
    
    def __init__(self, db_path: Path = DB_PATH):
        self.db_path = db_path
        self.docs_dir = DOCS_DIR
        self.docs_dir.mkdir(exist_ok=True)
    
    def get_stats(self):
        """Get overall statistics"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        stats = {}
        
        # Total investigations
        cursor.execute("SELECT COUNT(*) FROM investigations")
        stats['total'] = cursor.fetchone()[0]
        
        # By type
        cursor.execute("SELECT type, COUNT(*) FROM investigations GROUP BY type")
        stats['by_type'] = dict(cursor.fetchall())
        
        # By status
        cursor.execute("SELECT status, COUNT(*) FROM investigations GROUP BY status")
        stats['by_status'] = dict(cursor.fetchall())
        
        # Recent investigations
        cursor.execute("""
            SELECT id, status, created_at 
            FROM investigations 
            ORDER BY created_at DESC 
            LIMIT 10
        """)
        stats['recent'] = cursor.fetchall()
        
        # Chain stats
        cursor.execute("SELECT COUNT(DISTINCT chain_id) FROM investigations WHERE chain_id IS NOT NULL")
        stats['total_chains'] = cursor.fetchone()[0]
        
        conn.close()
        return stats
    
    def generate_markdown_dashboard(self) -> str:
        """Generate a markdown dashboard"""
        stats = self.get_stats()
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        report = [
            "# Nextflow Investigation Dashboard",
            f"\n**Generated:** {timestamp}\n",
            "## Overview\n",
            f"- **Total Investigations:** {stats['total']}",
            f"- **Resume Chains:** {stats['total_chains']}",
            ""
        ]
        
        # By type
        report.append("### Investigations by Type\n")
        for exp_type, count in stats['by_type'].items():
            report.append(f"- **{exp_type}:** {count}")
        report.append("")
        
        # By status
        report.append("### Investigations by Status\n")
        for status, count in stats['by_status'].items():
            status_emoji = {
                "completed": "✅",
                "failed": "❌",
                "running": "🔄",
                "planned": "📋",
                "archived": "📦"
            }.get(status, "❓")
            report.append(f"- **{status}** {status_emoji}: {count}")
        report.append("")
        
        # Recent investigations
        report.append("### Recent Investigations\n")
        report.append("| Investigation ID | Status | Created |")
        report.append("|---------------|--------|---------|")
        for exp_id, status, created in stats['recent']:
            report.append(f"| {exp_id[:40]} | {status} | {created} |")
        report.append("")
        
        # Save dashboard
        dashboard_file = self.docs_dir / f"dashboard_{datetime.now().strftime('%Y%m%d')}.md"
        with open(dashboard_file, "w") as f:
            f.write("\n".join(report))
        
        # Also save as latest
        latest_file = self.docs_dir / "dashboard_latest.md"
        with open(latest_file, "w") as f:
            f.write("\n".join(report))
        
        return str(dashboard_file)
    
    def generate_json_report(self) -> str:
        """Generate JSON report for programmatic access"""
        stats = self.get_stats()
        
        report = {
            "generated_at": datetime.now().isoformat(),
            "statistics": stats
        }
        
        json_file = self.docs_dir / "dashboard_latest.json"
        with open(json_file, "w") as f:
            json.dump(report, f, indent=2)
        
        return str(json_file)


def main():
    parser = argparse.ArgumentParser(description="Generate investigation dashboard")
    parser.add_argument(
        "--format",
        choices=["markdown", "json", "both"],
        default="markdown",
        help="Output format"
    )
    
    args = parser.parse_args()
    
    generator = DashboardGenerator()
    
    print("📊 Generating dashboard...")
    
    if args.format in ["markdown", "both"]:
        md_file = generator.generate_markdown_dashboard()
        print(f"✅ Markdown dashboard: {md_file}")
    
    if args.format in ["json", "both"]:
        json_file = generator.generate_json_report()
        print(f"✅ JSON report: {json_file}")
    
    print("\n📁 View with: cat docs/dashboard_latest.md")


if __name__ == "__main__":
    main()
