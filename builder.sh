#!/bin/bash

FILE_LOC="~/.template-builder/files/"
TEMP_LOC="~/.template-builder/.templates"

if ( -f $TEMP_LOC )
then
	case $1 in
		--help|-h)
			;;
	esac
else
	touch $TEMP_LOC
	printf "\nInitialised the template builder"
	~/.template-builder/builder.sh -h
fi
