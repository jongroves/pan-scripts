# PAN-SCRIPTS README
The scripts in this repo are some I've made to automate processes on Palo Alto firewalls. Hopefully this can help others out there who manage these awesome firewalls on a day to day basis! 

## Requirements
The following requirements are needed for most (if not all) of the above scripts. Additional requirements will be noted inside of the specific script folders if needed. 

### 1. Install pan-python package (https://pypi.org/project/pan-python/)
```
sudo apt-get install python-pip
sudo pip install pan-python
```

### 2. Create .panrc file using tags (http://api-lab.paloaltonetworks.com/keygen.html)
My scripts utilize tags created in the .panrc file to run so that bulk operations can be performed on multiple firewalls with different keys. The location of the .panrc file is important. It needs to either be in the users home folder or the same directory as the script. I prefer to place it in the script directory because some of my scripts need to be ran as root. 
```
cd /path/to/script/directory
panxapi.py -t [UNIQUE_TAG_NAME] -h [MGMT_IP_ADDRESS] -l [USERNAME] -k >> .panrc
Password: [enter password]
```
If all went well, you should see `keygen: success`. 

See example below:
```
cd /path/to/script/directory
panxapi.py -t PA-VM-01 -h 10.255.255.50 -l api_admin -k >> .panrc
Password: [api_admin password entered]
keygen: success

cat .panrc
# panxapi.py generated: 2024/01/28 10:50:35
hostname%PA-VM-01=10.255.255.50
api_key%PA-VM-01=LUFRPT0xVlJmZHBaVmNDLzEveXBsR3ptVk5uSWw3ejA9S0FDR...
```
Repeat the command for all firewalls you would like to automate actions for so that all keys and hostnames are stored in the .panrc file.

Finally modify permissions of the .panrc file to ensure it can only be accessed by your user:
```
chmod 600 .panrc
```
