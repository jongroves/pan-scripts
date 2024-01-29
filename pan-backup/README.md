# pan-backup README
This script can be used to automate the export of the device state file from a Palo Alto NGFW. 
- Bulk Script
   - This is a modified version of the main script that will loop through all tags stored in the .panrc file. Optionally, you can set the TAGS variable to be the contents of a text file for specific targeted groups of .panrc tags. 

## Prerequisites
- pan-python package & .panrc file (see main [README](/README.md) for more information)
