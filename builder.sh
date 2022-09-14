#!/bin/bash

FILE_LOC="~/.template-builder/files/"
TEMP_LOC="~/.template-builder/.templates"
ROOT=$(pwd)

if ( -f $TEMP_LOC )	# Checks if the file that saves the templates in exists.  If not it will create the file and then refer to the help command to give user assistance
then

	case $1 in

		--save|-s)	# Saves the current directory as a template

			printf "\nSaving the directory as a template structure\n"

			if ( $2 != "" )		# Tests to see if the template name exists.  If not the user is asked to enter it
			then

				OUTPUT=$2
			else

				printf "\nWhat would you like to name the template structure?"
				read OUTPUT
				printf "\n"
			fi

			for FILE in *		# Runs through every file in the current directory.  **Will fill more in when the code is built upon**
			do
				if ( -d $FILE )
				then
				else
				fi
			done
			;;

		--help|-h)

			;;
	esac
else

	touch $TEMP_LOC
	printf "\nInitialised the template builder"
	~/.template-builder/builder.sh -h
fi
