#!/bin/bash
# Clones a github repository

# import bash variables from utils.sh
. utils.sh

function clone_repo() {

	# check current working directory for app
	local CWD="$PWD"
	local git_app="$1"

	if [[ ! -d "$CWD/$git_app" ]]
	then
		echo -e "${cyan}Do you want to clone the repository with your personal access token?${clear} N|n OR Y|y"
		read -r response
		if [[ "$response" =~ ^[Nn]$ ]]
		then
			git clone https://github.com/Taiwopeter-babs/"$git_app".git
		elif [[ "$response" =~ ^[Yy]$ ]]
		then


			#echo -e "${cyan}Reading clone_repo.txt file${clear}"
			if [[ ! -f "$HOME/clone_repo.txt" ]]
			then
				echo -e "${red}clone_repo.txt was not found${clear}"
				echo -e "${cyan}Create a clone_repo.txt and save token with this style:${clear}"
				echo -e "GITHUB_TOKEN:VARIABLE_VALUE\nLines beginning with '#' will not be parsed"
				exit 1
			else
				echo -e "${green}Reading clone_repo.txt file for access token...${clear}"
				
				# Read lines in file
				while read -r line
				do
					# skip comments
					if [[ "$line" =~ ^# ]]
					then
						continue
					fi
					# read line into array
					IFS='=' read -ra line_array <<< "$line"

					# save token to variable
					if [[ "${line_array[0]}" =~ ^GITHUB_TOKEN$ ]]
					then
						local TOKEN="${line_array[1]}"
					fi
				done < "$HOME/clone_repo.txt"
				
				echo -e "${green}Cloning repo in progress...${clear}"

				git clone https://"$TOKEN"@github.com/Taiwopeter-babs/"$git_app".git

				# check action exit code
				exit_code="$?"

				if [ "$exit_code" != 0 ]
				then
					echo -e "${red}Repository was not cloned successfully.${clear}"
				fi
			fi
		fi
	else
		echo -e "${cyan}Repository already available locally\n"
		echo -e "${green}cd $CWD/$git_app${clear}"
	fi
}

# Help text
IFS='' read -r -d '' HELP_TEXT <<"EOF"
This is a bash script to help you clone a repository you have already created
or own on github. To start, simply run ./clone_repo <name of repository>
and wait for prompts.
Options:
./clone_repo <repo name>
./clone_repo help
EOF

# check command line arguments
if [ $# -eq 0 ]
then
	echo -e "${red}Argument is not passed.${clear}"
	echo -e "${cyan}USAGE: clone_repo <repo name>${clear} or clone_repo help"
	exit 1
else
	# display help text
	if [[ "$1" =~ ^help$ ]]
	then
		echo -e "${cyan}$HELP_TEXT${clear}"
		exit 0
	fi
	clone_repo "$1"
fi
