#!/usr/bin/env python3
"""
Fix DugisGuide Dungeon Format
Updates the dungeon files to match the working guide format exactly
"""

import os
import re
import sys

def fix_dungeon_format(file_path):
    """Fix the format of a dungeon guide to match working guides"""
    try:
        # Read the file
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Extract current registration info
        pattern = r'DugisGuideViewer:RegisterGuide\("([^"]*)", "([^"]*)", "([^"]*)", "([^"]*)", function\(\)'
        match = re.search(pattern, content)
        
        if match:
            title = match.group(1)
            next_guide = match.group(2)
            faction = match.group(3)
            guide_type = match.group(4)
            
            # Change guide type from "I" to "L" to match working guides
            new_guide_type = "L"
            
            # Build the replacement with proper format
            new_registration = f'DugisGuideViewer:RegisterGuide("{title}", "", "{faction}", "{new_guide_type}", function()'
            
            # Replace in content
            new_content = re.sub(pattern, new_registration, content)
            
            # Write back to file
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            filename = os.path.basename(file_path)
            print(f"Fixed: {filename}")
            print(f"  Changed type: {guide_type} -> {new_guide_type}")
            return True
        else:
            print(f"Could not find RegisterGuide pattern in {os.path.basename(file_path)}")
            return False
            
    except Exception as e:
        print(f"Error fixing {file_path}: {e}")
        return False

def fix_directory(dir_path):
    """Fix all .lua files in a directory"""
    if not os.path.isdir(dir_path):
        print(f"Directory not found: {dir_path}")
        return
    
    lua_files = [f for f in os.listdir(dir_path) if f.endswith('.lua')]
    
    print(f"Fixing {len(lua_files)} files in {dir_path}")
    print("=" * 50)
    
    fixed = 0
    for filename in lua_files:
        file_path = os.path.join(dir_path, filename)
        if fix_dungeon_format(file_path):
            fixed += 1
    
    print("=" * 50)
    print(f"Successfully fixed {fixed}/{len(lua_files)} files")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Fix DugisGuide Dungeon Format")
        print("Usage:")
        print("  python3 fix_dungeon_format.py <directory_path>")
        print("  python3 fix_dungeon_format.py <file_path>")
        print("")
        print("Examples:")
        print("  python3 fix_dungeon_format.py DugisGuide_Dungeons_Horde_En/")
        print("  python3 fix_dungeon_format.py DugisGuide_Dungeons_Alliance_En/")
        sys.exit(1)
    
    target_path = sys.argv[1]
    
    if os.path.isfile(target_path):
        fix_dungeon_format(target_path)
    elif os.path.isdir(target_path):
        fix_directory(target_path)
    else:
        print(f"Path not found: {target_path}")