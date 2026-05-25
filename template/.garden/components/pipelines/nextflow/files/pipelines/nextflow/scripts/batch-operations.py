#!/usr/bin/env python3
"""
Batch Operations for Nextflow Investigations
Bulk status updates, tag management, and parallel operations
"""

import argparse
import sqlite3
import sys
from pathlib import Path
from typing import List

SCRIPT_DIR = Path(__file__).parent
BASE_DIR = SCRIPT_DIR.parent
DB_PATH = BASE_DIR / ".registry" / "investigations.db"


class BatchOperations:
    """Perform batch operations on investigations"""
    
    def __init__(self, db_path: Path = DB_PATH):
        self.db_path = db_path
    
    def bulk_status_update(self, exp_ids: List[str], new_status: str):
        """Update status for multiple investigations"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        for exp_id in exp_ids:
            cursor.execute("""
                UPDATE investigations 
                SET status = ?, updated_at = datetime('now')
                WHERE id = ?
            """, (new_status, exp_id))
        
        conn.commit()
        count = cursor.rowcount
        conn.close()
        
        print(f"✅ Updated {count} investigation(s) to status: {new_status}")
    
    def bulk_add_tags(self, exp_ids: List[str], tags: List[str]):
        """Add tags to multiple investigations"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        for tag_name in tags:
            # Ensure tag exists
            cursor.execute("""
                INSERT OR IGNORE INTO tags (tag_name) VALUES (?)
            """, (tag_name,))
            
            cursor.execute("SELECT id FROM tags WHERE tag_name = ?", (tag_name,))
            tag_id = cursor.fetchone()[0]
            
            # Add tag to investigations
            for exp_id in exp_ids:
                cursor.execute("""
                    INSERT OR IGNORE INTO investigation_tags (investigation_id, tag_id)
                    VALUES (?, ?)
                """, (exp_id, tag_id))
        
        conn.commit()
        conn.close()
        
        print(f"✅ Added {len(tags)} tag(s) to {len(exp_ids)} investigation(s)")
    
    def bulk_archive(self, exp_ids: List[str]):
        """Archive multiple investigations"""
        self.bulk_status_update(exp_ids, "archived")
        print("📦 Investigations archived")
    
    def bulk_delete_tag(self, exp_ids: List[str], tag_name: str):
        """Remove tag from multiple investigations"""
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
                DELETE FROM investigation_tags 
                WHERE investigation_id = ? AND tag_id = ?
            """, (exp_id, tag_id))
        
        conn.commit()
        conn.close()
        
        print(f"✅ Removed tag '{tag_name}' from {len(exp_ids)} investigation(s)")
    
    def find_by_criteria(self, status: str = None, exp_type: str = None, 
                         tag: str = None) -> List[str]:
        """Find investigations matching criteria"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        query = "SELECT DISTINCT e.id FROM investigations e"
        conditions = []
        params = []
        
        if tag:
            query += " JOIN investigation_tags et ON e.id = et.investigation_id"
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
    parser = argparse.ArgumentParser(description="Batch operations on investigations")
    subparsers = parser.add_subparsers(dest="command", required=True)
    
    # Bulk status update
    status_parser = subparsers.add_parser("update-status", help="Bulk status update")
    status_parser.add_argument("status", help="New status")
    status_parser.add_argument("investigations", nargs="+", help="Investigation IDs")
    
    # Bulk add tags
    tag_parser = subparsers.add_parser("add-tags", help="Add tags to investigations")
    tag_parser.add_argument("--tags", nargs="+", required=True, help="Tags to add")
    tag_parser.add_argument("investigations", nargs="+", help="Investigation IDs")
    
    # Bulk archive
    archive_parser = subparsers.add_parser("archive", help="Archive investigations")
    archive_parser.add_argument("investigations", nargs="+", help="Investigation IDs")
    
    # Find by criteria
    find_parser = subparsers.add_parser("find", help="Find investigations by criteria")
    find_parser.add_argument("--status", help="Filter by status")
    find_parser.add_argument("--type", help="Filter by type")
    find_parser.add_argument("--tag", help="Filter by tag")
    
    args = parser.parse_args()
    
    batch = BatchOperations()
    
    if args.command == "update-status":
        batch.bulk_status_update(args.investigations, args.status)
    
    elif args.command == "add-tags":
        batch.bulk_add_tags(args.investigations, args.tags)
    
    elif args.command == "archive":
        batch.bulk_archive(args.investigations)
    
    elif args.command == "find":
        exp_ids = batch.find_by_criteria(args.status, args.type, args.tag)
        if exp_ids:
            print(f"\nFound {len(exp_ids)} investigation(s):\n")
            for exp_id in exp_ids:
                print(f"  {exp_id}")
        else:
            print("No investigations found matching criteria")


if __name__ == "__main__":
    main()
