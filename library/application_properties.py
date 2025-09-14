#!/usr/bin/python

# Copyright: (c) 2025, Digital AI

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: application_properties

short_description: Manage Java application.properties files

version_added: "1.0.0"

description: This module allows you to atomically update Java application.properties files by commenting out existing properties and adding new ones in a managed block.

options:
    path:
        description: Path to the application.properties file
        required: true
        type: str
    properties:
        description: Dictionary of properties to set (key-value pairs)
        required: true
        type: dict
    backup:
        description: Create a backup file before making changes
        required: false
        default: true
        type: bool
    comment_existing:
        description: Comment out existing properties with the same keys
        required: false
        default: true
        type: bool
    marker:
        description: Text to use as block marker
        required: false
        default: "ANSIBLE MANAGED BLOCK - Application Properties"
        type: str

author:
    - Your Name (@yourusername)
'''

EXAMPLES = r'''
# Update application properties
- name: Update application.properties
  application_properties:
    path: /opt/app/config/application.properties
    properties:
      server.port: "8080"
      database.url: "jdbc:mysql://localhost/mydb"
      app.name: "myapp"
    backup: true
    comment_existing: true
'''

RETURN = r'''
changed:
    description: Whether the file was modified
    type: bool
    returned: always
    sample: true
backup_file:
    description: Path to the backup file if created
    type: str
    returned: when backup=true
    sample: /opt/app/config/application.properties.2025-09-13@12:34:56~
properties_added:
    description: Number of properties added/updated
    type: int
    returned: always
    sample: 3
properties_commented:
    description: Number of existing properties commented out
    type: int
    returned: always
    sample: 2
'''

import os
import re
import shutil
from datetime import datetime
from ansible.module_utils.basic import AnsibleModule


def backup_file(file_path):
    """Create a backup of the original file"""
    timestamp = datetime.now().strftime("%Y-%m-%d@%H:%M:%S~")
    backup_path = f"{file_path}.{timestamp}"
    shutil.copy2(file_path, backup_path)
    return backup_path


def read_properties_file(file_path):
    """Read the properties file content"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.readlines()
    except IOError:
        return []


def write_properties_file(file_path, lines):
    """Write content to properties file"""
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)


def comment_existing_properties(lines, properties_dict):
    """Comment out existing properties that match our keys"""
    commented_count = 0
    property_keys = list(properties_dict.keys())
    
    # Create regex pattern to match any of our property keys with optional spaces around =
    escaped_keys = [re.escape(key) for key in property_keys]
    pattern = re.compile(r'^(' + '|'.join(escaped_keys) + r')\s*=(.*)$')
    
    new_lines = []
    in_ansible_block = False
    
    for line in lines:
        stripped_line = line.strip()
        
        # Check if we're entering or leaving an Ansible managed block
        if "# BEGIN ANSIBLE MANAGED" in stripped_line:
            in_ansible_block = True
            new_lines.append(line)
            continue
        elif "# END ANSIBLE MANAGED" in stripped_line:
            in_ansible_block = False
            new_lines.append(line)
            continue
        
        # Don't comment properties inside Ansible managed blocks
        if in_ansible_block:
            new_lines.append(line)
            continue
            
        # Check if this line matches our properties and isn't already commented
        match = pattern.match(stripped_line)
        if match and not stripped_line.startswith('#'):
            # Comment out the existing property
            new_lines.append(f"# {line.rstrip()}  # commented by ansible\n")
            commented_count += 1
        else:
            new_lines.append(line)
    
    return new_lines, commented_count


def remove_existing_ansible_block(lines, marker):
    """Remove existing Ansible managed block"""
    begin_marker = f"# BEGIN {marker}"
    end_marker = f"# END {marker}"
    
    new_lines = []
    in_block = False
    
    for line in lines:
        if begin_marker in line:
            in_block = True
            continue
        elif end_marker in line:
            in_block = False
            continue
        elif not in_block:
            new_lines.append(line)
    
    return new_lines


def add_ansible_block(lines, properties_dict, marker):
    """Add Ansible managed block with properties"""
    begin_marker = f"# BEGIN {marker}\n"
    end_marker = f"# END {marker}\n"
    
    # Add a blank line before the block if the file doesn't end with one
    if lines and not lines[-1].endswith('\n'):
        lines.append('\n')
    if lines and lines[-1].strip():
        lines.append('\n')
    
    # Add the managed block
    lines.append(begin_marker)
    for key, value in properties_dict.items():
        lines.append(f"{key}={value}\n")
    lines.append(end_marker)
    
    return lines


def main():
    module_args = dict(
        path=dict(type='str', required=True),
        properties=dict(type='dict', required=True),
        backup=dict(type='bool', required=False, default=True),
        comment_existing=dict(type='bool', required=False, default=True),
        marker=dict(type='str', required=False, default='ANSIBLE MANAGED BLOCK - Application Properties')
    )

    result = dict(
        changed=False,
        properties_added=0,
        properties_commented=0
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    file_path = module.params['path']
    properties_dict = module.params['properties']
    backup = module.params['backup']
    comment_existing = module.params['comment_existing']
    marker = module.params['marker']

    # Check if file exists, create if it doesn't
    if not os.path.exists(file_path):
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        # Create empty file
        with open(file_path, 'w') as f:
            f.write('')

    # Read original file
    original_lines = read_properties_file(file_path)
    working_lines = original_lines.copy()

    # Comment out existing properties if requested
    if comment_existing:
        working_lines, commented_count = comment_existing_properties(working_lines, properties_dict)
        result['properties_commented'] = commented_count
    
    # Remove any existing Ansible managed block
    working_lines = remove_existing_ansible_block(working_lines, marker)
    
    # Add new Ansible managed block
    working_lines = add_ansible_block(working_lines, properties_dict, marker)
    result['properties_added'] = len(properties_dict)

    # Check if file would change
    if working_lines != original_lines:
        result['changed'] = True
        
        if not module.check_mode:
            # Create backup if requested
            if backup and original_lines:
                backup_path = backup_file(file_path)
                result['backup_file'] = backup_path
            
            # Write the updated file
            write_properties_file(file_path, working_lines)

    module.exit_json(**result)


if __name__ == '__main__':
    main()
