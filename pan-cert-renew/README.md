# PAN-CERT-RENEW README

## The Script Explained

Below is a simplified description on the flow of the [script](pan-cert-renew.sh):
1. Request certificate renewal.
2. Convert full chain and private key into PFX certificate using a randomly generated temporary password.
3. Import the PFX certificate and private key into the firewall, then remove the local copy.
4. (optional) Update certificate in GlobalProtect profiles.
5. Commit changes on Palo Alto Firewall.

## Prerequisites

To get started, you'll need the following in place:
1. A linux-based host with the following packages installed:
   - openssl, pan-python, certbot, certbot-dns-cloudflare (if using Cloudflare)
   - ```
     sudo apt install python-pip certbot openssl
     sudo pip install pan-python
     sudo pip install certbot-dns-cloudflare
     ```
2. Certbot compatible DNS provider account
   - A complete list of certbot DNS plugins can be found [here](https://eff-certbot.readthedocs.io/en/latest/using.html#dns-plugins).
   - In this example, I'm using Cloudflare. Below are the steps needed within Cloudflare:
     - Login to your Cloudflare account and grab your API key:
       - My Profile > API Tokens > Create Token
       - Use the "Edit zone DNS" template
         
         ![image](/images/pan-cert-renew-cloudflare-02.png)
         
       - Fill in the form. Add appropriate client IP filtering for added security. See example below:
         
         ![image](/images/pan-cert-renew-cloudflare-01.png)
         
       - Continue to Summary > Create Token > Copy API key
       - Create your .cloudflare.ini following the format below:
       - ```
         dns_cloudflare_api_key = _8Uc8Mm68bqGjMBqwaZWAT6fnLo9R4XMT
         ```
       - Update permissions of .cloudflare.ini so that it can only be accessed by your user:
         ```
         chmod 600 .cloudflare.ini
         ```
3. A populated .panrc file. See main [README](/README.md) for info on how to create this.

## Initialize Certbot - Cloudflare

We'll run the command manually first to make sure everything gets setup and runs correctly. 

- Replace `*.mydomain.com` with your certificate FQDN or a comma-seperatated list of domains.
  - (Note: The first domain will be the subnect CN. All other domains will appear as SANs.)
- This example is requesting a wildcard cerficiate for `*.mydomain.com`:
  ```
  cloudflare-credentials /path/to/.cloudflare.ini -d *.mydomain.com --preferred-challenges dns-01
  ```

## Script Variables Explained

Below is a brief description on the variables used in the script:
- `TAG` This is the tag we generated for the particular ip/hostname of the firewall when we created our .panrc file.
- `CLOUDFLARE_CREDS` The path to our .cloudflare.ini file.
- `FQDN` Our orginizations FQDN. This is used for the certbot request.
- `TEMP_PWD` A temporary password created for the openssl step of the script.
- `CERT_NAME` The name the certificate will have inside the Palo Alto configuration.
- `GP_PORTAL_TLS_PROFILE` The name of our GlobalProtect Portal TLS profile inside of our Palo Alto configuration.
- `GP_GW_TLS_PROFILE` The name of our GlobalProtect Gateway TLS profile inside of our Palo Alto configuration (this could be and probably is the same as the portal TLS profile name).

## Let's automate this thing!

Now the entire point of doing this is to automate this so we never have to touch it again (fingers crossed). To do that, we can just simply create a cron job to run this script on a regular basis. 

1. Create custom cronjob:
   ```
   sudo nano /etc/cron.d/pan-cert-renew-cron
   ```
2. Insert the following into the file you just created in order to send output to a log file in case any issues arise. The example below will execute every Saturday at midnight (tweak schedule according to your needs):
   ```
   PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
   SHELL=/bin/bash

   0 0 * * 6 root (/bin/date && /path/to/pan-cert-renew.sh) >> /var/log/pan-cert-renew.log 2>&1
   ```
3. Be aware of renewal limts! See the official documentation outlining those [here](https://letsencrypt.org/docs/rate-limits/).
