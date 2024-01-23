# THIS IS WORK IN PROGRESS - YOU ARE WELCOME TO CONTRIBUTE

# LSF notes 
This README is intended for basic universal LSF best practictes, gathering 
FAQs and notes on LSF, etc.  Condor specific information is kept on Confluence. 

# LSF IBM Community Addition

C-AWS has installed the Community edition (free) of IBM Spectrum LSF

This is a reference from IBM

https://www.ibm.com/docs/en/spectrum-lsf/10.1.0?topic=started-quick-reference
 
# LSF Admin and LSF Admin panel

LSF processes run under a dedicated account in C-AWS.  There is a browser based GUI for administration and monitoring of the LSF queues and setup.

See also the internal C-AWS IT Info page, slack Jeff for questions.


# C-AWS LSF info

This is RAW.

Before accessing PAC you'll need to configure certificate authentication, once done you'll be able to access lsf web gui

In firefox:

Select Tools > Options > Privacy & Security.

Select Security > Certificates, then click View Certificates.

The Authorities tab is displayed in Certificate Manager.

Click the Your Certificates tab.

Click Import and select the lsfadmin.p12 file.

When a dialog is displayed asking for cert password please provide lsfadmin user password
in chrome:

Select the kebab menu (three vertical dots) and select Settings > Privacy and security.

Select Security > Manage device certificates.

The Certificates dialog is displayed.

Select the Your Certificates tab.

Click Import and select the lsfadmin.p12 file.

When a dialog is displayed asking for cert password please provide lsfadmin user password

Once done you can access the PAC site using below URL - it will only work from GUI machine or if you're on VPN:

https://172.19.3.1:8443/

Since we are using https with self signed certificate you might see prompt about connection not being secure (certificate authority is not being recognised), please select to continue regardless & turn off warning for this site.

The certificate is located in /data/tools/LSF/lsfadmin.p12

# LSF FAQ

Waiting for 1st post

