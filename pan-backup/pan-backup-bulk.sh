#!/bin/bash

#Requirements: pan-python, .panrc file in current directory 

#Gets all tags used in .panrc file for target firewalls
TAGS=$(cat .panrc | grep hostname | awk -F % '{print $2}' | awk -F = '{print $1}')

#OR set TAGS to custom text file containing list of specific .panrc tag names
#TAGS=$(cat firewalls.txt)

#Path to main backup folder. A subfolder per tag will be created inside this directory if they do not exist.
BACKUP_DIR=/path/to/backup/folder

for TAG in $TAGS; do

    #Path to tag-specific backup folder.
    TAG_DIR=$BACKUP_DIR/$TAG

    #Check to see if $TAG directory exists. If not, create it.
    if [ ! -d "$TAG_DIR" ]; then
        echo "Directory $TAG_DIR does not exist. Creating..."
        mkdir "$TAG_DIR"
    fi

    echo "Getting device-state export for tag $TAG"

    #exported file parameters
    FILENAME=device_state_cfg-$(date +"%Y%m%d-%H%M%S").tgz

    #PAN-OS device state export
    panxapi.py -t $TAG --export device-state --dst $FILE_DIR/$FILENAME

done