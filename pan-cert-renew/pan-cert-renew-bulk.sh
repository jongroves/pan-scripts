#!/bin/bash

#Requirements: openssl, pan-python, certbot, .panrc file in current directory

#Gets all tags used in .panrc file for target firewalls
TAGS=$(cat .panrc | grep hostname | awk -F % '{print $2}' | awk -F = '{print $1}')

#OR set TAGS to custom text file containing list of specific .panrc tag names
#TAGS=$(cat firewalls.txt)

#Clourflare Variables
CLOUDFLARE_CREDS=.cloudflare.ini
FQDN=mydomain.com

#Random temp password for PFX cert
TEMP_PWD=$(openssl rand -hex 15)

#Palo Alto config variables
CERT_NAME=LetsEncryptWildcard
GP_PORTAL_TLS_PROFILE=gp1-portal-tls-profile
GP_GW_TLS_PROFILE=gp1-gw-tls-profile

#Request wildcard cert update from Cloudflare
sudo /usr/local/bin/certbot certonly --dns-cloudflare --dns-cloudflare-credentials $CLOUDFLARE_CREDS -d *.$FQDN -n --agree-tos --force-renew

#Convert full chain and private key into PFX cert for upload to Palo Alto firewall
sudo openssl pkcs12 -export \
  -out letsencrypt_pkcs12.pfx \
  -inkey /etc/letsencrypt/live/$FQDN/privkey.pem \
  -in /etc/letsencrypt/live/$FQDN/fullchain.pem \
  -passout pass:$TEMP_PWD

for TAG in $TAGS; do

    #Import PFX cert into firewall
    panxapi.py -t $TAG \
      --import certificate \
      --file letsencrypt_pkcs12.pfx \
      --ad-hoc "certificate-name=$CERT_NAME&format=pkcs12&passphrase=$TEMP_PWD"

    #Import PFX private key into firewall
    panxapi.py -t $TAG \
      --import private-key \
      --file letsencrypt_pkcs12.pfx \
      --ad-hoc "certificate-name=$CERT_NAME&format=pkcs12&passphrase=$TEMP_PWD"

    #Update certificate in GP portal TLS profile. [Note: This is only needed on first run if cert name does not change.]
    #panxapi.py -h $PAN_MGMT -K $API_KEY -S "<certificate>$CERT_NAME</certificate>" "/config/shared/ssl-tls-service-profile/entry[@name='$GP_PORTAL_TLS_PROFILE']"

    #Update certificate in GP gateway TLS profile [Note: This is only needed on first run if cert name does not change.]
    #panxapi.py -h $PAN_MGMT -K $API_KEY -S "<certificate>$CERT_NAME</certificate>" "/config/shared/ssl-tls-service-profile/entry[@name='$GP_GW_TLS_PROFILE']"

    #Commit changes on Palo
    panxapi.py -t $TAG -C '' --sync

done

#Remove local PFX certificate
sudo rm letsencrypt_pkcs12.pfx
