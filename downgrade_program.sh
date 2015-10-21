#!/bin/bash
#title         :downgrade_program
#description   :Program right downgrader for newly installed system
#author        :P.GINDRAUD
#author_contact:pgindraud@gmail.com
#created_on    :2015-05-14
#usage         :./downgrade_program <CMD>
#usage_info    :use command '--help'
#options       :debug
#notes         :
readonly VERSION='1.0.0'
# The MIT License (MIT)
# 
# Copyright (c) 2015 Pierre GINDRAUD
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#==============================================================================
DOWNGRADE_USER_root=""
DOWNGRADE_GRP_admin=""

#========== INTERNAL OPTIONS ==========#


#========== INTERNAL VARIABLES ==========#
IS_DEBUG=0
IS_VERBOSE=0
IS_ADMIN_DOWNGRADE=0
IS_APPLY=0
IS_LIST=0

readonly DEFAULT_IFS=$IFS

#========== INTERNAL FUNCTIONS ==========#

# Print help msg
function _usage() {
  echo -e "Usage : $0 [OPTION...] COMMAND

This script set some modification on several system command to prevent bad usage
from unauthorized users

Version : $VERSION

Command :
  apply     apply all modification to concerned files
  show      dry run only show concerned files

Options :
  --source=FILE   Import the list of command to treat
  -ls, --list-prop   Run ls command after each modification
  -h, --help      Display this help message
  -v, --verbose   Show more running messages
  -d, --debug     Show debug messages

Return code :
  0     Success
  200   Need to be root
  201   Bad system arguments
  202   Missing COMMAND in shell args
  203   Missing a system needed program
"
}

# Print a msg to stdout if verbose option is set
# @param[string] : the msg to write in stdout
function _echo() {
  if [[ $IS_VERBOSE -eq 1 ]]; then
    echo -e "$*"
  fi
}

# Print a msg to stdout if verbose option is set
# @param[string] : the msg to write in stdout
function _echon() {
  if [[ $IS_VERBOSE -eq 1 ]]; then
    echo -ne "$*"
  fi
}

# Print a msg to stderr if verbose option is set
# @param[string] : the msg to write in stderr
function _error() {
  if [[ $IS_VERBOSE -eq 1 ]]; then
    echo -e "Error : $*" 1>&2
  fi
}

# Print a msg to stdout if debug verbose is set
# @param[string] : the msg to write in stdout
function _debug() {
  if [[ $IS_DEBUG -eq 1 ]]; then
    echo -e "debug: $*"
  fi
}

# Check if the script is run by root or not. If not, prompt error and exit
function _isRunAsRoot() {
  if [[ "$(id -u)" != "0" ]]; then
    _error "This script must be run as root."
    exit 200
  fi
}

# Check if an option is set to a 'true' value or not
# @param[string] : value to check
# @return[int] : 0 if value is consider as true
#                1 if not
function _isTrue() {
  [[ "$1" =~ ^(true|TRUE|True|1)$ ]]
}

#========== PROGRAM FUNCTIONS ==========#
# Downgrade function
# @param [string] : the list of file to treat
# @param [string] : the USER:GROUP string that define the targeted username and
#                   groupname for the file
function _treatFiles() {
  IFS=$'\n'
  for line in $1; do
    # if a sharp is found drop this line, it's a comment line
    if [[ ${line:0:1} = "#" ]]; then
      _debug "  => comment : $line"
      continue
    fi
    IFS=$DEFAULT_IFS
    for file in $line; do
      path=$(which "${file}" 2>/dev/null)
      if [[ -n $path ]]; then
        _echon "Trying \e[33m${file}\e[0m : "
        _downgradeCommand "$path" "$2"
        if [[ $? -ne 0 ]]; then
          _echo " => \e[31mAborting\e[0m"
        else
          _echo " => \e[32mSuccess\e[0m"
        fi
        if [[ $IS_LIST -eq 1 ]]; then
          ls -l "$path"
        fi
      else
        _echo "Skipping \e[33m${file}\e[0m : \e[34mNot found\e[0m"
      fi
    done
    IFS=$'\n'
  done
  IFS=$DEFAULT_IFS
}

# Try to apply new chmod
# @param [string] : the path of the file to treat
# @param [string] : the USER:GROUP string that define the targeted username and
#                   groupname for the file
# return [integer] : 0 if success
#                    1 if right already set
#                    2 otherwise
function _downgradeCommand() {
  local owner
  local group
  local right
  local target_owner
  local target_group
  if [[ $# -lt 2 ]]; then
    return 2
  fi

  right=$(stat -c '%a' "$1")
  owner=$(stat -c '%U' "$1")
  group=$(stat -c '%G' "$1")
  target_owner=$(expr match "$2" "^\(.*\):.*$")
  target_group=$(expr match "$2" "^.*:\(.*\)$")

  # OWNER CHECKING
  if [[ $owner != $target_owner ]]; then
    _echon " chown $target_owner"
    if [[ $IS_APPLY -eq 1 ]]; then
      chown "$target_owner" "$1"
      # error during chown
      if [[ $? -ne 0 ]]; then
        _echon " \e[31mNOK\e[0m "
        return 2
      else
        _echon " \e[32mOK\e[0m "
      fi
    fi
  fi

  # GROUP CHECKING
  if [[ $group != $target_group ]]; then
    _echon " chgrp $target_group"
    if [[ $IS_APPLY -eq 1 ]]; then
      chgrp "$target_group" "$1"
      # error during chown
      if [[ $? -ne 0 ]]; then
        _echon " \e[31mNOK\e[0m "
        return 2
      else
        _echon " \e[32mOK\e[0m "
      fi
    fi
  fi

  # RIGHT CHECKING
  if [[ ! $right =~ ..0 ]]; then
    _echon " chmod o=---"
    if [[ $IS_APPLY -eq 1 ]]; then
      chmod 'o=---' "$1"
      # error during chmod
      if [[ $? -ne 0 ]]; then
        _echon " \e[31mNOK\e[0m "
        return 2
      else
        _echon " \e[32mOK\e[0m "
      fi
    fi
  fi

  return 0
}




#========== MAIN FUNCTION ==========#
# Main
# @param[] : same of the script
# @return[int] : X the exit code of the script
function main() {
  local r

  ### ARGUMENTS PARSING
  for i in $(seq $(($#+1))); do
    #catch main arguments
    case $1 in
    -v|--verbose) IS_VERBOSE=1;;
    -d|--debug) IS_DEBUG=1;;
    -ls|--list-prop) IS_LIST=1;;
    --source=*)
      source "$(echo $1 | cut -d '=' -f 2-)"
      if [[ $? -ne 0 ]]; then exit 1; fi
      ;;
    -h|--help)
      _usage
      exit 0;;
    -*) _error "invalid option -- '$1'"
        exit 201;;
    *)  if [[ $# -ge 1 ]]; then # GOT NEEDED ARGUMENTS
          main_command=$1
          break #stop reading arguments
        else
          _error 'missing command'
          exit 202
        fi
      ;;
    esac

    if [[ $# -lt 1 ]]; then
      _error 'missing command'
      exit 202
    fi

    shift
  done
  grep --extended-regexp '^admin' /etc/group 2>/dev/null 1>&2
  if [[ $? -eq 0 ]]; then
    IS_ADMIN_DOWNGRADE=1
  else
    IS_ADMIN_DOWNGRADE=0
  fi

  _isRunAsRoot

  ### MAIN RUNNING
  case "$main_command" in
  apply)
    _echo " * Applying system downgrade"
    IS_APPLY=1
    _echo " * ROOT downgrade"
    _treatFiles "$DOWNGRADE_USER_root" "root:root"
    if [[ $IS_ADMIN_DOWNGRADE -eq 1 ]]; then
      _echo " * ADMIN downgrade"
      _treatFiles "$DOWNGRADE_GRP_admin" "root:admin"
    fi
    ;;
  show)
    IS_VERBOSE=1
    _echo " * This is the list of potential downgrade"
    _echo " * ROOT downgrade"
    _treatFiles "$DOWNGRADE_USER_root" "root:root"
    if [[ $IS_ADMIN_DOWNGRADE -eq 1 ]]; then
      _echo " * ADMIN downgrade"
      _treatFiles "$DOWNGRADE_GRP_admin" "root:admin"
    fi
    ;;
  *)
    echo "Usage: $0 {apply|show}"
    ;;
  esac
}


###### RUNNING ######
main "$@"
