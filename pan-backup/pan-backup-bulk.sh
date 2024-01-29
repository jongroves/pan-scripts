#!/bin/bash

#Requirements: pan-python, .panrc file in current directory 

#Gets all tags used in .panrc file for target firewalls
TAGS=$(cat .panrc | grep hostname | awk -F % '{print $2}' | awk -F = '{print $1}')

#OR set TAGS to custom text file containing list of specific .panrc tag names
#TAGS=$(cat firewalls.txt)

#Global variables:
FILE_DIR=/path/to/backup/folder

for TAG in $TAGS; do

    echo "Getting device-state export for tag $TAG"

    #exported file parameters
    FILENAME=$TAG/device_state_cfg-$(date +"%Y%m%d-%H%M%S").tgz

    #PAN-OS device state export
    panxapi.py -t $TAG --export device-state --dst $FILE_DIR/$FILENAME

done