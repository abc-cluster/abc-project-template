#!/usr/bin/env python3
"""
Batch Operations for Nextflow Experiments
Bulk status updates, tag management, and parallel operations
"""

import argparse
import sqlite3
import sys
from pathlib import Path
from typing import List

SCRIPT_DIR = Path(__file__).parent
BASE_DIR = SCRIPT_DIR.parent
DB_PATH = BASE_DIR / ".registry" / "experiments.db"


class BatchOperations:
    """Perform batch operations on experiments"""
    
    def __init__(self, db_path: Path = DB_PATH):
        self.db_path = db_path
    
    def bulk_status_update(self, exp_ids: List[str], new_status: str):
        """Update status for multiple experiments"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        for exp_id in exp_ids:
            cursor.execute("""
                UPDATE experiments 
                SET status = ?, updated_at = datetime('now')
                WHERE id = ?
            """, (new_status, exp_id))
        
        conn.commit()
        count = cursor.rowcount
        conn.close()
        
        print(f"✅ Updated {count} experiment(s) to status: {new_status}")
    
    def bulk_add_tags(self, exp_ids: List[str], tags: List[str]):
        """Add tags to multiple experiments"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        for tag_name in tags:
            # Ensure tag exists
            cursor.execute("""
                INSERT OR IGNORE INTO tags (tag_name) VALUES (?)
            """, (tag_name,))
            
            cursor.execute("SELECT id FROM tags WHERE tag_name = ?", (tag_name,))
            tag_id = cursor.fetchone()[0]
            
            # Add tag to experiments
            for exp_id in exp_ids:
                cursor.execute("""
                    INSERT OR IGNORE INTO experiment_tags (experiment_id, tag_id)
                    VALUES (?, ?)
                """, (exp_id, tag_id))
        
        conn.commit()
        conn.close()
        
        print(f"✅ Added {len(tags)} tag(s) to {len(exp_ids)} experiment(s)")
    
    def bulk_archive(self, exp_ids: List[str]):
        """Archive multiple experiments"""
        self.bulk_status_update(exp_ids, "archived")
        print("📦 Experiments archived")
    
    def bulk_delete_tag(self, exp_ids: List[str], tag_name: str):
        """Remove tag from multiple experiments"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("SELECT id FROM tags WHERE tag_name = ?", (tag_name,))
        result = cursor.fetchone()
        if not result:
            print(f"Tag '{tag_name}' not found")
            conn.close()
            return
        
        tag_id = result[0]
        
        for exp_id in exp_ids:
            cursor.execute("""
                DELETE FROM experiment_tags 
                WHERE experiment_id = ? AND tag_id = ?
            """, (exp_id, tag_id))
        
        conn.commit()
        conn.close()
        
        print(f"✅ Removed tag '{tag_name}' from {len(exp_ids)} experiment(s)")
    
    def find_by_criteria(self, status: str = None, exp_type: str = None, 
                         tag: str = None) -> List[str]:
        """Find experiments matching criteria"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        query = "SELECT DISTINCT e.id FROM experiments e"
        conditions = []
        params = []
        
        if tag:
            query += " JOIN experiment_tags et ON e.id = et.experiment_id"
            query += " JOIN tags t ON et.tag_id = t.id"
            conditions.append("t.tag_name = ?")
            params.append(tag)
        
        if status:
            conditions.append("e.status = ?")
            params.append(status)
        
        if exp_type:
            conditions.append("e.type = ?")
            params.append(exp_type)
        
        if conditions:
            query += " WHERE " + " AND ".join(conditions)
        
        cursor.execute(query, params)
        exp_ids = [row[0] for row in cursor.fetchall()]
        conn.close()
        
        return exp_ids


def main():
    parser = argparse.ArgumentParser(description="Batch operations on experiments")
    subparsers = parser.add_subparsers(dest="command", required=True)
    
    # Bulk status update
    status_parser = subparsers.add_parser("update-status", help="Bulk status update")
    status_parser.add_argument("status", help="New status")
    status_parser.add_argument("experiments", nargs="+", help="Experiment IDs")
    
    # Bulk add tags
    tag_parser = subparsers.add_parser("add-tags", help="Add tags to experiments")
    tag_parser.add_argument("--tags", nargs="+", required=True, help="Tags to add")
    tag_parser.add_argument("experiments", nargs="+", help="Experiment IDs")
    
    # Bulk archive
    archive_parser = subparsers.add_parser("archive", help="Archive experiments")
    archive_parser.add_argument("experiments", nargs="+", help="Experiment IDs")
    
    # Find by criteria
    find_parser = subparsers.add_parser("find", help="Find experiments by criteria")
    find_parser.add_argument("--status", help="Filter by status")
    find_parser.add_argument("--type", help="Filter by type")
    find_parser.add_argument("--tag", help="Filter by tag")
    
    args = parser.parse_args()
    
    batch = BatchOperations()
    
    if args.command == "update-status":
        batch.bulk_status_update(args.experiments, args.status)
    
    elif args.command == "add-tags":
        batch.bulk_add_tags(args.experiments, args.tags)
    
    elif args.command == "archive":
        batch.bulk_archive(args.experiments)
    
    elif args.command == "find":
        exp_ids = batch.find_by_criteria(args.status, args.type, args.tag)
        if exp_ids:
            print(f"\nFound {len(exp_ids)} experiment(s):\n")
            for exp_id in exp_ids:
                print(f"  {exp_id}")
        else:
            print("No experiments found matching criteria")


if __name__ == "__main__":
    main()
