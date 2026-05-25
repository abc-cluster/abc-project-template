#!/usr/bin/env python3
"""
Investigation Registry Management CLI
Manages SQLite database for Nextflow pipeline investigation tracking
"""

import sqlite3
import sys
import json
from pathlib import Path
from datetime import datetime
from typing import Optional, List, Dict, Any

# Paths
SCRIPT_DIR = Path(__file__).parent
BASE_DIR = SCRIPT_DIR.parent
DB_PATH = BASE_DIR / ".registry/investigations.db"
SCHEMA_PATH = BASE_DIR / ".registry/schemas/schema.sql"
VIEWS_DIR = BASE_DIR / ".registry/views"


class InvestigationRegistry:
    """Manages investigation database operations"""
    
    def __init__(self, db_path: Path = DB_PATH):
        self.db_path = db_path
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
    
    def get_connection(self) -> sqlite3.Connection:
        """Get database connection"""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row  # Enable column access by name
        return conn
    
    def init_db(self):
        """Initialize database with schema and views"""
        print(f"🔨 Initializing database: {self.db_path}")
        
        # Create schema
        conn = self.get_connection()
        with open(SCHEMA_PATH) as f:
            conn.executescript(f.read())
        print(f"✅ Schema created from {SCHEMA_PATH}")
        
        # Apply views
        if VIEWS_DIR.exists():
            for view_file in VIEWS_DIR.glob("*.sql"):
                with open(view_file) as f:
                    conn.executescript(f.read())
                print(f"✅ View created: {view_file.stem}")
        
        conn.close()
        print(f"✅ Database initialized successfully")
    
    def create_investigation(
        self,
        exp_id: str,
        exp_type: str,
        scenario: str,
        phase: str = "pipeline-development",
        researcher: str = "unknown",
        purpose: str = "",
        project_name: str = "",
        dataset: str = "",
        tags: List[str] = None
    ) -> bool:
        """Register new investigation"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            # Insert investigation
            cursor.execute("""
                INSERT INTO investigations (
                    id, type, phase, scenario, status, 
                    researcher, purpose, project_name, dataset
                )
                VALUES (?, ?, ?, ?, 'planned', ?, ?, ?, ?)
            """, (exp_id, exp_type, phase, scenario, researcher, purpose, project_name, dataset))
            
            # Add tags if provided
            if tags:
                for tag in tags:
                    cursor.execute(
                        "INSERT INTO investigation_tags (investigation_id, tag) VALUES (?, ?)",
                        (exp_id, tag)
                    )
            
            conn.commit()
            print(f"✅ Investigation registered: {exp_id}")
            return True
            
        except sqlite3.IntegrityError as e:
            print(f"❌ Investigation already exists: {exp_id}")
            return False
        except Exception as e:
            print(f"❌ Error creating investigation: {e}")
            return False
        finally:
            conn.close()
    
    def update_status(self, exp_id: str, status: str) -> bool:
        """Update investigation status"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute(
                "UPDATE investigations SET status = ? WHERE id = ?",
                (status, exp_id)
            )
            conn.commit()
            
            if cursor.rowcount == 0:
                print(f"❌ Investigation not found: {exp_id}")
                return False
            
            print(f"✅ Status updated: {exp_id} -> {status}")
            return True
            
        except Exception as e:
            print(f"❌ Error updating status: {e}")
            return False
        finally:
            conn.close()
    
    def update_git_info(self, exp_id: str, git_commit: str, git_branch: str, is_dirty: bool = False) -> bool:
        """Update git information for investigation"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute("""
                UPDATE investigations 
                SET git_commit = ?, git_branch = ?, is_dirty = ?
                WHERE id = ?
            """, (git_commit, git_branch, 1 if is_dirty else 0, exp_id))
            conn.commit()
            return True
        except Exception as e:
            print(f"❌ Error updating git info: {e}")
            return False
        finally:
            conn.close()
    
    def link_tower(self, exp_id: str, tower_run_id: str, workspace: str = "default") -> bool:
        """Link Tower run to investigation"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute("""
                UPDATE investigations 
                SET tower_run_id = ?, workspace = ?
                WHERE id = ?
            """, (tower_run_id, workspace, exp_id))
            conn.commit()
            print(f"✅ Tower run linked: {exp_id} -> {tower_run_id}")
            return True
        except Exception as e:
            print(f"❌ Error linking Tower run: {e}")
            return False
        finally:
            conn.close()
    
    def add_execution(
        self,
        execution_id: str,
        exp_id: str,
        status: str = "planned",
        scenario: str = "local-local",
        head_location: str = "local",
        tasks_location: str = "local"
    ) -> bool:
        """Add execution record"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute("""
                INSERT INTO executions (
                    execution_id, investigation_id, status,
                    head_location, tasks_location
                )
                VALUES (?, ?, ?, ?, ?)
            """, (execution_id, exp_id, status, head_location, tasks_location))
            conn.commit()
            print(f"✅ Execution registered: {execution_id}")
            return True
        except Exception as e:
            print(f"❌ Error adding execution: {e}")
            return False
        finally:
            conn.close()
    
    def add_result(
        self,
        exp_id: str,
        name: str,
        value: str,
        unit: str = "",
        category: str = "",
        file: str = ""
    ) -> bool:
        """Add result metric"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute("""
                INSERT INTO results (
                    investigation_id, name, value, unit, category, file
                )
                VALUES (?, ?, ?, ?, ?, ?)
            """, (exp_id, name, value, unit, category, file))
            conn.commit()
            print(f"✅ Result added: {name} = {value} {unit}")
            return True
        except Exception as e:
            print(f"❌ Error adding result: {e}")
            return False
        finally:
            conn.close()
    
    def list_investigations(self, exp_type: Optional[str] = None, status: Optional[str] = None) -> List[Dict[str, Any]]:
        """List investigations with optional filters"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        query = "SELECT * FROM investigations WHERE 1=1"
        params = []
        
        if exp_type:
            query += " AND type = ?"
            params.append(exp_type)
        
        if status:
            query += " AND status = ?"
            params.append(status)
        
        query += " ORDER BY created_at DESC"
        
        cursor.execute(query, params)
        rows = cursor.fetchall()
        conn.close()
        
        return [dict(row) for row in rows]
    
    def view_investigation(self, exp_id: str) -> Optional[Dict[str, Any]]:
        """View single investigation details"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        cursor.execute("SELECT * FROM investigations WHERE id = ?", (exp_id,))
        row = cursor.fetchone()
        
        if not row:
            conn.close()
            return None
        
        exp = dict(row)
        
        # Get executions
        cursor.execute("SELECT * FROM executions WHERE investigation_id = ?", (exp_id,))
        exp['executions'] = [dict(r) for r in cursor.fetchall()]
        
        # Get results
        cursor.execute("SELECT * FROM results WHERE investigation_id = ?", (exp_id,))
        exp['results'] = [dict(r) for r in cursor.fetchall()]
        
        # Get tags
        cursor.execute("SELECT tag FROM investigation_tags WHERE investigation_id = ?", (exp_id,))
        exp['tags'] = [r['tag'] for r in cursor.fetchall()]
        
        conn.close()
        return exp
    
    def search_by_tag(self, tag: str) -> List[Dict[str, Any]]:
        """Search investigations by tag"""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT e.* FROM investigations e
            JOIN investigation_tags t ON e.id = t.investigation_id
            WHERE t.tag = ?
            ORDER BY e.created_at DESC
        """, (tag,))
        
        rows = cursor.fetchall()
        conn.close()
        return [dict(row) for row in rows]


def main():
    """CLI entry point"""
    if len(sys.argv) < 2:
        print("Usage: register-investigation.py <command> [args]")
        print("\nCommands:")
        print("  init-db                          Initialize database")
        print("  create --id ID --type TYPE       Create investigation")
        print("  update-status --id ID --status STATUS")
        print("  link-tower --id ID --tower-run-id RID")
        print("  add-result --id ID --name NAME --value VAL")
        print("  list [--type TYPE] [--status STATUS]")
        print("  view --id ID                     View investigation details")
        print("  search-tag --tag TAG             Search by tag")
        sys.exit(1)
    
    registry = InvestigationRegistry()
    command = sys.argv[1]
    
    # Parse arguments
    args = {}
    for i in range(2, len(sys.argv), 2):
        if i + 1 < len(sys.argv):
            key = sys.argv[i].lstrip('-')
            args[key] = sys.argv[i + 1]
    
    # Execute command
    if command == "init-db":
        registry.init_db()
    
    elif command == "create":
        registry.create_investigation(
            exp_id=args.get('id'),
            exp_type=args.get('type', 'development'),
            scenario=args.get('scenario', 'local-local'),
            phase=args.get('phase', 'pipeline-development'),
            researcher=args.get('researcher', 'unknown'),
            purpose=args.get('purpose', ''),
            project_name=args.get('project', ''),
            dataset=args.get('dataset', ''),
            tags=args.get('tags', '').split(',') if args.get('tags') else []
        )
    
    elif command == "update-status":
        registry.update_status(args.get('id'), args.get('status'))
    
    elif command == "update-git-info":
        registry.update_git_info(
            args.get('id'),
            args.get('commit', ''),
            args.get('branch', ''),
            args.get('dirty', '').lower() == 'true'
        )
    
    elif command == "link-tower":
        registry.link_tower(
            args.get('id'),
            args.get('tower-run-id'),
            args.get('workspace', 'default')
        )
    
    elif command == "add-result":
        registry.add_result(
            args.get('id'),
            args.get('name'),
            args.get('value'),
            args.get('unit', ''),
            args.get('category', ''),
            args.get('file', '')
        )
    
    elif command == "list":
        investigations = registry.list_investigations(
            exp_type=args.get('type'),
            status=args.get('status')
        )
        print(f"\n📋 Found {len(investigations)} investigations:\n")
        for exp in investigations:
            print(f"  {exp['id']:<60} | {exp['type']:<12} | {exp['status']:<10} | {exp['created_at']}")
    
    elif command == "view":
        exp = registry.view_investigation(args.get('id'))
        if exp:
            print(json.dumps(exp, indent=2))
        else:
            print(f"❌ Investigation not found: {args.get('id')}")
    
    elif command == "search-tag":
        investigations = registry.search_by_tag(args.get('tag'))
        print(f"\n🏷️  Found {len(investigations)} investigations with tag '{args.get('tag')}':\n")
        for exp in investigations:
            print(f"  {exp['id']:<60} | {exp['type']:<12} | {exp['status']}")
    
    else:
        print(f"❌ Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
