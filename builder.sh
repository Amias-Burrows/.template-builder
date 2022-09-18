#!/bin/bash

	# Colour Variables

NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 190)
BLUE=$(tput setaf 153)
RED=$(tput setaf 1)
BOLD=$(tput bold)
UNDERLINE=$(tput smul)

FILE_LOC=~/.template-builder/files/
TEMP_LOC=~/.template-builder/.templates
ROOT=$(pwd)
REC_SEP="\u001E"
GRP_SEP="\u001D"
TXT_SRT="\u0002"
#set -x

get_temp_names() {
	TEMPS=()
	while IFS= read -r LINE		# Runs through the file contents and prints out template names
	do

		TEMPS+=(${LINE%%\\u001D*})
		
	done < ${TEMP_LOC}
	echo "${TEMPS[@]}"
}


add() {		# Adds file to template directory
	printf "\nAdd function\n"

	FILE_COUNT=$(ls ${FILE_LOC} | wc -l)
	EXT=${2##*.}

	cp ./${2} ${FILE_LOC}${FILE_COUNT}.${EXT}

	mv ./${2} ./${FILE_COUNT}${2}

	if [ $(echo $?) == 0 ]
	then
		printf "\nFile copied into the template directory\n"
	else
		printf "\n${RED}${BOLD}Error!${NORMAL} File not copied successfully. Error code 001\n"
	fi
}


store_file() {	# Asks user if they want this file in the template.  Copies the file over to the template folder if it is wanted

	printf "\nDo you want to store ${Blue}${BOLD}${FILE}${NORMAL} in the template? Y/N "
	read RESPONSE

	if [ $RESPONSE == "Y" ]	|| [ $RESPONSE == "y" ]
	then		# Adds file to template folder and gets ID and NAME

		add null $FILE
		get_id

	elif [ $RESPONSE == "N" ] || [ $RESPONSE == "n" ]
	then		# Ignores the file and continues with the rest of the program

	
		printf "\nIgnoring ${BLUE}${BOLD}${FILE}${NORMAL}\n"
		IGNORE=true

	else		# Handles error from user not entering correct input

		printf "\nPlease respond using either ${YELLOW}${BOLD}Y${NORMAL} or ${GREEN}${BOLD}N${NORMAL}\n"
		store_file

	fi
}


get_id() {
	TEMP_ID=${NAME%*}	# Extrapolates ID from File Name

	NAME=${NAME##*}	# Extrapolates File Name from File Name
}


save() {	# Saves the template structure

	for FILE in *		# Runs through every file in the current directory
	do

		if [ -d $FILE ]
			# Checks if it is a Directory or File
		then
				# If it's a directory it marks it's parent directory, notes down the details for this directory and enters it to discover all the files within the directory

			PARENT=$CUR_LOC

				# | File name | Parent Directory ID | Dir\File | Current ID |
			OUTPUT+="${FILE}${REC_SEP}${CUR_LOC}${REC_SEP}0${REC_SEP}${DIR_COUNT}${GRP_SEP}"

			CUR_LOC=$DIR_COUNT	# Sets location to the ID of this directory and updates the Directory count for the next directory to have a unique ID
			((DIR_COUNT++))

			cd ./${FILE}	# Enters the current directory, runs the function within the directory and then leaves after the function has finished
			save
			cd ../

			CUR_LOC=$PARENT		# Updates the current locoation back to this Directory so the files don't get given the wrong parent
		else		# Handles files
			IGNORE=false

			NAME=${FILE%.*}		# Extrapolates File Name

			EXT=${FILE##*.}		# Extrapolates File Extension

			if [[ "${NAME}" == *""* ]]	# Checks if file name has special character in it
			then

				get_id
			else

				store_file
			fi

			if [ $IGNORE == false ]		# Checks whether the file is being ignored or not
			then

					# | File name | Parent Directory ID | Dir\File | File Type |
				OUTPUT+="${NAME}${REC_SEP}${CUR_LOC}${REC_SEP}1${REC_SEP}${TEMP_ID}${GRP_SEP}"
			fi
			IGNORE=false
		fi
	done
}


name_template() {	# Requests name from the user for the template and handles empty name
	printf "\nWhat would you like to name the template structure? "
	read OUTPUT

	if [ -z $OUTPUT ]	# Checks if user has entered anything
	then

		printf "\nPlease name the template for your convenience later on\n"
		name_template	# Calls the question again to get a usable response
	else

		OUTPUT+="${GRP_SEP}"
		printf "\n"	# Prints a line break to keep the next print on it's own line.  Nothing worse than leaving a script and the input line is on the end of the last bit of text
	fi
}


case $1 in

	--save|-s)	# Saves the current directory as a template
		CUR_LOC=0	# Initialises the directory ID for the root directory and indicates that there is one directory in the project
		DIR_COUNT=1

		printf "\nSaving the directory as a template structure\n"	# Indicates to the user that something is happening

		if [ "${2}" != "" ]		# Tests to see if the template name exists.  If not the user is asked to enter it
		then

			OUTPUT="${2}${GRP_SEP}"
		else

			name_template	# Calls the naming function above.  It's in a function to act as a 'goto' command for if someone uses it wrong
		fi

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
			add null $2
		else
			printf "\nError. The file at ${BLUE}${BOLD}${2}${NORMAL} was not recognised\n"
		fi

		;;

	--create|-c)

		if [[ "${2}" != "" ]] && [ -f $TEMP_LOC ]
		then
			LIST=$(get_temp_names)
			for ENTRY in $LIST
			do
				if [ $2 == $ENTRY ]
				then
					# This is where we note down the number.  Can't be bothered to think of the varibale name so I'm gonna go get riggedy riggedy recked with Fern
				fi
			done
		else
			printf "Error"
		fi

		;;

	--list|-l)		# Lists the saved template files
		printf "\nPreparing to print the names of your saved templates\n"
		LIST=$(get_temp_names)
		if [[ "${LIST}" != "" ]]
		then
			for NAME in $LIST
			do
				printf "\n - ${GREEN}${UNDERLINE}${NAME}${NORMAL}\n"
			done
		else
			printf "\nYou don't seem to have any templates saved.  to save one create a template folder structure and run ${YELLOW}${BOLD}~/.template-builder/builder.sh --save${NORMAL}\n"
		fi
		;;

	--help|-h|*)
		printf "\nHelp Page\n"
		;;
esac
