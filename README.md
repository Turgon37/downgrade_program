# Downgrade Program script

This project is licensed under the terms of the MIT license

This script change system command right to disallow 'other' and restrict to root or admin group.
All command that must be treated must be in two variable :
  * DOWNGRADE_USER_root for command that must only run by root
  * DOWNGRADE_GRP_admin for command that require to be in 'admin' group

## Usage

Run the script as root user manually from it location like

```bash
  ./downgrade_program.sh --source=program_list.sh -s apply
```

Use the `--help` command to show the full list of commands and options

##### Requires:
  * Bash