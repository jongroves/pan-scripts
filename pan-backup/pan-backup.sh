#!/bin/bash

#Requirements: pan-python, .panrc file in current directory 

#tag used in .panrc file
TAG="PA-VM-01"

#exported file parameters
FILENAME=$TAG/device_state_cfg-$(date +"%Y%m%d-%H%M%S").tgz
FILE_DIR=/path/to/backup/folder/

#PAN-OS device state export
panxapi.py -t $TAG --export device-state --dst /$FILE_DIR/$FILENAME
