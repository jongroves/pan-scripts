# pan-backup README
This script can be used to automate the export of the device state file from a Palo Alto NGFW. 

## Prerequisites
pan-python package & .panrc file (see main [README](/README.md) for more information)

## Bulk Script
This is a modified version of the main script that will loop through tags stored in the .panrc file by default. Optionally, you can create a text file of specific .panrc tag names (one per line) like below:
```
#Gets all tags used in .panrc file for target firewalls
#TAGS=$(cat .panrc | grep hostname | awk -F % '{print $2}' | awk -F = '{print $1}')

#OR set TAGS to custom text file containing list of specific .panrc tag names
TAGS=$(cat firewalls.txt)
```
