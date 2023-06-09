#!/usr/bin/bash -e

# Note: The -e flag will cause the script to exit if any command fails.

# Description: shred it all
# Author: @nothingbutlucas
# Version: 1.0.0
# License: GNU General Public License v3.0

# Colours and uses

red='\033[0;31m'    # Something went wrong
green='\033[0;32m'  # Something went well
yellow='\033[0;33m' # Warning
blue='\033[0;34m'   # Info
purple='\033[0;35m' # When asking something to the user
cyan='\033[0;36m'   # Something is happening
grey='\033[0;37m'   # Show a command to the user
nc='\033[0m'        # No Color

sign_wrong="${red}[-]${nc}"
sign_good="${green}[+]${nc}"
sign_warn="${yellow}[!]${nc}"
sign_info="${blue}[i]${nc}"
sign_ask="${purple}[?]${nc}"
sign_doing="${cyan}[~]${nc}"
sign_cmd="${grey}[>]${nc}"

wrong="${red}"
good="${green}"
warn="${yellow}"
info="${blue}"
ask="${purple}"
doing="${cyan}"
cmd="${grey}"

trap ctrl_c INT

function ctrl_c() {
	exit_script
}

function exit_script() {
	echo -e "${sign_good}Exiting script"
	tput cnorm
	exit 0
}

function start_script() {
	tput civis
	echo ""
	echo -e "${sign_good}Starting script"
}

function help_panel() {
	echo -e "Usage: ${good}$0 -d DIRECTORY${info}"
	echo -e "\n\t${cmd}Example: $0 -d $HOME/Downloads/${nc}"

	exit_script
}

function wait_for_confirmation() {
	echo -ne "\n${sign_ask} Press ${ask}enter${nc} to continue... or ${ask}ctrl + c${nc} to exit" && read enter
	if [[ $enter != "" ]]; then
		exit_script
	fi
}

function shred_dir {
	for file in "$1"/*; do
		if [[ -f "$file" ]]; then
			scrub -p dod "$file" && shred -zun 10 -v "$file"
		elif [[ -d "$file" ]]; then
			shred_dir "$file"
		fi
	done
}

# Main function

continue=False

while getopts ":yd:" arg; do
	case $arg in
	d) directory=$OPTARG ;;
	y) continue=True ;;
	?)
		echo -e "${wrong}[!]${nc}Invalid option: -$OPTARG\n"
		help_panel
		;;
	esac
done

function main() {
	if [ -d "$1" ]; then
		echo -e "${sign_warn} ${warn}All the files and directorys on $1 will be deleted.${nc}"
		echo -e "${sign_cmd} ${cmd}ls: $(ls -la $1)\n${nc}"
		echo -e "${sign_ask} ${ask}Do you want to continue?${nc}"
		if [ $continue = False ]; then
			wait_for_confirmation
		fi
		shred_dir "$1"
		echo -e "${sign_info} ${info}All the files where deleted securely. Deleting empty directorys${nc}"
		rm -rfv "$1"
		echo -e "${sign_good} ${good}All the directorys on $1 where deleted.${nc}"
	else
		echo -e "${sign_wrong} ${wrong}Please provide a valid directory path as an argument.${nc}"
		help_panel
	fi
}

# Script starts here

start_script
main "$directory"
exit_script
