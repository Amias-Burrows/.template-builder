#!/bin/bash

	# Colour Variables

NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 190)
BLUE=$(tput setaf 153)
RED=$(tput setaf 1)
BOLD=$(tput bold)
UNDERLINE=$(tput smul)

	# File locations

FILE_LOC=~/.template-builder/files/
TEMP_LOC=~/.template-builder/.templates
ROOT=$(pwd)

	# Special characters

REC_SEP="\u001E"
GRP_SEP="\u001D"
TXT_SRT="\u0002"

set -x	# DEBUGGING

get_temp_line() {		# Finds the correct template from a given name
	while IFS= read -r LINE
	do

		if ( $1 == ${LINE%%\\u001D*} )
		then
			echo "${LINE}"
		fi
		
	done < ${TEMP_LOC}
}



name_try_again() {	# Requests name from the user for the template and handles empty name
	printf "\nWhat would you like to name the ${1}? "
	read local RESPONSE

	if [ -z $RESPONSE ]	# Checks if user has entered anything
	then

		printf "\nPlease name the ${1} for your convenience later on\n"
		name_try_again ${1}	# Calls the question again to get a usable response
	else

		echo "${RESPONSE}${GRP_SEP}"
	fi
}


case $1 in

	--save|-s)	# Saves the current directory as a template
		local OUTPUT-""
		local CUR_LOC=0	# Initialises the directory ID for the root directory and indicates that there is one directory in the project
		local DIR_COUNT=1

		printf "\nSaving the directory as a template structure\n"	# Indicates to the user that something is happening

		if [ "${2}" != "" ]		# Tests to see if the template name has been entered.  If not the user is asked to enter it
		then
			local CONFLICT=$(get_temp_line $2)

			if [ $CONFLICT != "" ]
			then
				OUTPUT="${2}${GRP_SEP}"
			else
				printf "\nThe name ${2} seems to be taken.  Try another one or exit with ${YELLOW}${BOLD}ctrl C${NORMAL}\n"
				OUTPUT=$(name_try_again "Template Structure")
			fi

		else

			name_template	# Calls the naming function above.  It's in a function to act as a 'goto' command for when someone uses it wrong
		fi

		save() {	# Saves the template structure

			for FILE in *		# Runs through every file in the current directory
			do

				if [ -d $FILE ]
					# Checks if it is a Directory or File
				then
						# If it's a directory it marks it's parent directory, notes down the details for this directory and enters it to discover all the files within the directory

					local PARENT=$CUR_LOC

						# | File name | Parent Directory ID | Dir\File | Current ID |
					local OUTPUT+="${FILE}${REC_SEP}${CUR_LOC}${REC_SEP}0${REC_SEP}${DIR_COUNT}${GRP_SEP}"

					local CUR_LOC=$DIR_COUNT	# Sets location to the ID of this directory and updates the Directory count for the next directory to have a unique ID
					((DIR_COUNT++))

					cd ./${FILE}	# Enters the current directory, runs the function within the directory and then leaves after the function has finished
					save
					cd ../

					local CUR_LOC=$PARENT		# Updates the current locoation back to this Directory so the files don't get given the wrong parent
				else		# Handles files
					local IGNORE=false

					local NAME=${FILE%.*}		# Extrapolates File Name

					local EXT=${FILE##*.}		# Extrapolates File Extension

					if [[ "${NAME}" == *""* ]]	# Checks if file name has special character in it
					then

						TEMP_ID=${NAME%*}	# Extrapolates ID from File Name

						NAME=${NAME##*}	# Extrapolates File Name from File Name
					else

						store_file() {	# Asks user if they want this file in the template.  Copies the file over to the template folder if it is wanted

							printf "\nDo you want to store ${Blue}${BOLD}${FILE}${NORMAL} in the template? Y/N "
							read local RESPONSE

							if [ $RESPONSE == "Y" ]	|| [ $RESPONSE == "y" ]
							then		# Adds file to template folder and gets ID and NAME

								add null $FILE
								get_id

							elif [ $RESPONSE == "N" ] || [ $RESPONSE == "n" ]
							then		# Ignores the file and continues with the rest of the program


								printf "\nIgnoring ${BLUE}${BOLD}${FILE}${NORMAL}\n"

							else		# Handles error from user not entering correct input

								printf "\nPlease respond using either ${YELLOW}${BOLD}Y${NORMAL} or ${GREEN}${BOLD}N${NORMAL}\n"
								store_file

							fi
						}
						store_file
					fi

					if [ $IGNORE == false ]		# Checks whether the file is being ignored or not
					then

							# | File name | Parent Directory ID | Dir\File | File Type |
						OUTPUT+="${NAME}${REC_SEP}${CUR_LOC}${REC_SEP}1${REC_SEP}${TEMP_ID}${GRP_SEP}"
					fi
					local IGNORE=false
				fi
			done
		}

		save

		if [ -f $TEMP_LOC ]	# If the file exists then we add a linebreak to the start of the output.  This ensures that if we have to create a file for this then we won't have an empty line at the start of the file or no line breaks to differenciate the different templates
		then

			$OUTPUT="\n${OUTPUT}"
		fi

		echo $OUTPUT >> $TEMP_LOC	# Error prone bit.  Don't know why but it's showing an error of 'no such file or directory' at the location in $TEMP_LOC whilst if I just copy the text in that variable and paste it there it works.  The command >> should create a file if one doesn't exist
		;;

	--add|-a)	# Adds file to template files

		if [ -f $2 ]		# Checks if file exists in location specified
		then
			local FILE_COUNT=$(ls ${FILE_LOC} | wc -l)
			local EXT=${2##*.}
		
			cp ./${2} ${FILE_LOC}${FILE_COUNT}.${EXT}
		
			mv ./${2} ./${FILE_COUNT}${2}
		
			if [ $(echo $?) == 0 ]
			then
				printf "\nFile copied into the template directory\n"
			else
				printf "\n${RED}${BOLD}Error!${NORMAL} File not copied successfully. Error code 001\n"
			fi
		else
			printf "\nError. The file at ${BLUE}${BOLD}${2}${NORMAL} was not recognised\n"
		fi
		;;

	--create|-c)	# Uses a template folder structure that's been previously saved

		if [[ "${2}" != "" ]] && [ -f $TEMP_LOC ]
		then
			local TEMP=$(get_temp_line $2)
			printf "\n${TEMP}\n"
		else
			printf "\n${RED}${BOLD}Error${NORMAL} Please enter the name of the template you wish to use.\n"
		fi

		;;

	--list|-l)		# Lists the saved template files
		local EXISTS=false
		local OUTPUT="\nPreparing to print the names of your saved templates\n"

		while IFS= read -r LINE
		do

			OUTPUT+="\n - ${GREEN}${UNDERLINE}${LINE%%\\u001D*}${NORMAL}\n"
			EXISTS=true
		done < ${TEMP_LOC}
		if [ $EXISTS = true ]
		then
			printf "${OUTPUT}"
		else
			printf "\nYou don't seem to have any templates saved.  to save one create a template folder structure and run ${YELLOW}${BOLD}~/.template-builder/builder.sh --save${NORMAL}\n"
		fi
		;;

	--help|-h|*)
		printf "\n${GREEN}${UNDERLINE}--help${NORMAL} / ${GREEN}${UNDERLINE}-h${NORMAL}\n${YELLOW}Pulls up the list of commands you can use with this program${NORMAL}\n"
		printf "\n${GREEN}${UNDERLINE}--list${NORMAL} / ${GREEN}${UNDERLINE}-l${NORMAL}\n${YELLOW}Lists the templates you've saved so far${NORMAL}"
		printf "\n${GREEN}${UNDERLINE}--save${NORMAL} / ${GREEN}${UNDERLINE}-s${NORMAL}${BLUE} [template name]\n${YELLOW}Saves the current durectory as a template.${NORMAL}\n"
		printf "\n${GREEN}${UNDERLINE}--create${NORMAL} / ${GREEN}${UNDERLINE}-c${NORMAL}${BLUE} [template name]\n${YELLOW}Creates a project from a saved template.${NORMAL}\n"
		printf "\n${GREEN}${UNDERLINE}--add${NORMAL} / ${GREEN}${UNDERLINE}-a${NORMAL}${BLUE} [file name]\n${YELLOW}Adds a new file to be referred to in templates.${NORMAL}\n"
		;;
esac
