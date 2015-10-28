# Downgrade Program script

This project is licensed under the terms of the MIT license

This script change system command right according to a simply defined policy

## Usage

Run the script as root user manually from it location like

```bash
  ./downgrade_program.sh --source=program_list.sh -s apply
```

Use the `--help` command to show the full list of commands and options

The program_list in the repository is given as example file, it does'nt contains all downgradable commands

## Configuration

The configuration must be declared into the CONFIG shell variable. this variable support a per-line configuration. Each line describe how to downgrade rights of a list of commands.
Each line take at most 4 arguments in

  * `list:LISTNAME` LISTNAME is the name of the bash variable from which retrieve the list of command
   in this list, each command is listed per line or space separated. A line which start with a sharp # is considered as comment
  * `user:USERNAME` the username of the new owner of all commands
  * `group:GROUPNAME` the group to set all commands in
  * other text word not in the aboves syntaxes are considered as mode options and are pass to chmod tool.

##### Requires:
  * Bash