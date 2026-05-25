#!/usr/bin/env python3
"""
Script to recursively add .gitkeep files to empty directories
Created: 2025-06-11 20:49:02 UTC
Author: abhi18av
"""

import os
import sys
import argparse
import datetime
import getpass
from pathlib import Path

def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Add .gitkeep files to all empty directories recursively."
    )
    parser.add_argument(
        "directory",
        nargs="?",
        default=".",
        help="Target directory (defaults to current directory)"
    )
    return parser.parse_args()

def is_dir_effectively_empty(directory):
    """
    Check if a directory is empty or only contains .gitkeep files and empty directories.
    """
    # Skip .git directories
    if ".git" in directory.parts:
        return False

    # Check contents
    has_real_content = False
    for item in directory.iterdir():
        if item.is_file() and item.name != ".gitkeep":
            has_real_content = True
            break
        elif item.is_dir():
            # Recursively check if subdirectory has real content
            if not is_dir_effectively_empty(item):
                has_real_content = True
                break

    return not has_real_content

def add_gitkeep_files(target_dir):
    """Add .gitkeep files to empty directories."""
    target_path = Path(target_dir).resolve()

    if not target_path.is_dir():
        print(f"Error: Directory '{target_dir}' does not exist.")
        sys.exit(1)

    print(f"Adding .gitkeep files to empty directories in: {target_path}")
    print(f"Started at: {datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')} UTC")
    print(f"Running as: {getpass.getuser()}")
    print("-" * 40)

    added_count = 0
    existing_count = 0

    # Process all directories
    for root, dirs, files in os.walk(target_path, topdown=True):
        # Skip .git directories
        dirs[:] = [d for d in dirs if d != ".git"]

        path = Path(root)

        # Check if directory is empty
        if len(files) == 0 and len(dirs) == 0:
            gitkeep_path = path / ".gitkeep"
            if gitkeep_path.exists():
                print(f"EXISTING: {gitkeep_path}")
                existing_count += 1
            else:
                gitkeep_path.touch()
                print(f"CREATED:  {gitkeep_path}")
                added_count += 1

    # Second pass for directories that contain only .gitkeep files and empty subdirectories
    for directory in sorted(target_path.glob("**/*")):
        if directory.is_dir() and ".git" not in directory.parts:
            gitkeep_path = directory / ".gitkeep"

            # If directory doesn't have a .gitkeep and is effectively empty
            if not gitkeep_path.exists() and is_dir_effectively_empty(directory):
                gitkeep_path.touch()
                print(f"CREATED:  {gitkeep_path} (dir with only empty subdirs)")
                added_count += 1

    print("-" * 40)
    print("Summary:")
    print(f"- Added {added_count} .gitkeep files")
    print(f"- Found {existing_count} existing .gitkeep files")
    print(f"Completed at: {datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')} UTC")

def main():
    """Main function."""
    args = parse_arguments()
    add_gitkeep_files(args.directory)

if __name__ == "__main__":
    main()
