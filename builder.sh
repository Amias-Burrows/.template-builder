#!/bin/bash

FILE_LOC="~/.template-builder/files/"
TEMP_LOC="~/.template-builder/.templates"
ROOT=$(pwd)
REC_SEP="|"
GRP_SEP="{}"
TXT_SRT="\u0002"

add() {		# Adds file to template directory
	printf "\nAdd function\n"
}


save () {	# Saves the 

	printf "\nDirectory ID - ${CUR_LOC}\n"	# DEBUGGING

	for FILE in *		# Runs through every file in the current directory
	do

		if [ -d $FILE ]
			# Checks if it is a Directory or File
		then
				# If it's a directory it marks it's parent directory, notes down the details for this directory and enters it to discover all the files within the directory

			PARENT=$CUR_LOC

				# | File name | Parent Directory ID | Dir\File | Current ID |
			OUTPUT+="${FILE}${REC_SEP}${CUR_LOC}${REC_SEP}0${REC_SEP}${DIR_COUNT}${GRP_SEP}"
			printf "\nDirectory - ${FILE}\n"	# DEBUGGING

			CUR_LOC=$DIR_COUNT	# Sets location to the ID of this directory and updates the Directory count for the next directory to have a unique ID
			((DIR_COUNT++))

			cd ./${FILE}	# Enters the current directory, runs the function within the directory and then leaves after the function has finished
			save
			cd ../

			CUR_LOC=$PARENT		# Updates the current locoation back to this Directory so the files don't get given the wrong parent
		else

			NAME=${FILE%.*}		# Extrapolates File Name
			printf "\nFile Name - ${NAME}\n"	# DEBUGGING

			EXT=${FILE##*.}		# Extrapolates File Extension
			printf "\nFile Extension - ${EXT}\n"	# DEBUGGING

				# | File name | Parent Directory ID | Dir\File | File Type |
			OUTPUT+="${NAME}${REC_SEP}${CUR_LOC}${REC_SEP}1${REC_SEP}${EXT}${GRP_SEP}"
			printf "\nFile - ${FILE}\n"		# DEBUGGING
		fi
	done
}

case $1 in

	--save|-s)	# Saves the current directory as a template
		CUR_LOC=0	# Initialises the directory ID for the root directory and indicates that there is one directory in the project
		DIR_COUNT=1

		printf "\nSaving the directory as a template structure\n"	# Indicates to the user that something is happening

		printf "\nTemplate name: ${2}\n"	# DEBUGGING
		if [ "${2}" != "" ]		# Tests to see if the template name exists.  If not the user is asked to enter it
		then

			OUTPUT="${2}${GRP_SEP}"
		else
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

			name_template	# Calls the naming function above.  It's in a function to act as a 'goto' command for if someone uses it wrong
		fi

		save

		printf "\n${OUTPUT}\n"		# DEBUGGING

		if [ -f $TEMP_LOC ]	# If the file exists then we add a linebreak to the start of the output.  This ensures that if we have to create a file for this then we won't have an empty line at the start of the file or no line breaks to differenciate the different templates
		then

			$OUTPUT="\n${OUTPUT}"
		fi

		echo $OUTPUT >> $TEMP_LOC	# Error prone bit.  Don't know why but it's showing an error of 'no such file or directory' at the location in $TEMP_LOC whilst if I just copy the text in that variable and paste it there it works.  The command >> should create a file if one doesn't exist
		;;

	--add|-a)	# Adds file to template files
		if [ -z $2 ]
		then
			printf ""	# Temp
		else
			printf ""	# Temp
		fi

		;;

	--help|-h|*)
		printf "\nHelp Page\n"
		;;
esac
