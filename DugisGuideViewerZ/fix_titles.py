#!/usr/bin/env python3
"""
Fix DugisGuide Dungeon Titles
Updates the titles in converted dungeon files to use proper dungeon names
"""

import os
import re
import sys

def extract_dungeon_name_from_filename(filename):
    """Extract dungeon name from filename like '15_16_Ragefire_Chasm.lua'"""
    # Remove extension and level prefix
    name = filename.replace('.lua', '')
    # Remove level numbers (everything before and including the second underscore)
    parts = name.split('_')
    if len(parts) >= 3:
        # Join everything after the level numbers
        dungeon_name = '_'.join(parts[2:])
        # Convert underscores to spaces and title case
        dungeon_name = dungeon_name.replace('_', ' ')
        return dungeon_name
    return name

def extract_level_range_from_filename(filename):
    """Extract level range from filename like '15_16_Ragefire_Chasm.lua'"""
    match = re.match(r'(\d+)_(\d+)_', filename)
    if match:
        return f"({match.group(1)}-{match.group(2)})"
    return ""

def fix_file_title(file_path):
    """Fix the title in a converted dungeon file"""
    try:
        # Read the file
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Extract dungeon info from filename
        filename = os.path.basename(file_path)
        dungeon_name = extract_dungeon_name_from_filename(filename)
        level_range = extract_level_range_from_filename(filename)
        
        # Create proper title
        proper_title = f"{dungeon_name} {level_range}"
        
        # Find and replace the RegisterGuide line
        # Look for pattern: DugisGuideViewer:RegisterGuide("...", "", "...", "...", function()
        pattern = r'DugisGuideViewer:RegisterGuide\("([^"]*)", "([^"]*)", "([^"]*)", "([^"]*)", function\(\)'
        match = re.search(pattern, content)
        
        if match:
            current_title = match.group(1)
            next_guide = match.group(2)
            faction = match.group(3)
            guide_type = match.group(4)
            
            # Build the replacement
            new_registration = f'DugisGuideViewer:RegisterGuide("{proper_title}", "", "{faction}", "{guide_type}", function()'
            
            # Replace in content
            new_content = re.sub(pattern, new_registration, content)
            
            # Write back to file
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            print(f"Fixed: {filename}")
            print(f"  Old title: {current_title}")
            print(f"  New title: {proper_title}")
            return True
        else:
            print(f"Could not find RegisterGuide pattern in {filename}")
            return False
            
    except Exception as e:
        print(f"Error fixing {file_path}: {e}")
        return False

def fix_directory_titles(dir_path):
    """Fix titles in all .lua files in a directory"""
    if not os.path.isdir(dir_path):
        print(f"Directory not found: {dir_path}")
        return
    
    lua_files = [f for f in os.listdir(dir_path) if f.endswith('.lua')]
    
    print(f"Fixing titles in {len(lua_files)} files in {dir_path}")
    print("=" * 50)
    
    fixed = 0
    for filename in lua_files:
        file_path = os.path.join(dir_path, filename)
        if fix_file_title(file_path):
            fixed += 1
    
    print("=" * 50)
    print(f"Successfully fixed {fixed}/{len(lua_files)} files")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Fix DugisGuide Dungeon Titles")
        print("Usage:")
        print("  python3 fix_titles.py <directory_path>")
        print("  python3 fix_titles.py <file_path>")
        print("")
        print("Examples:")
        print("  python3 fix_titles.py DugisGuide_Dungeons_Horde_En/")
        print("  python3 fix_titles.py DugisGuide_Dungeons_Alliance_En/")
        sys.exit(1)
    
    target_path = sys.argv[1]
    
    if os.path.isfile(target_path):
        fix_file_title(target_path)
    elif os.path.isdir(target_path):
        fix_directory_titles(target_path)
    else:
        print(f"Path not found: {target_path}")