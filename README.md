# PowerShell---System-Health-Check
----------------------------------------

Introduction
-------------

The Powershell script perform daily health checkup of different Windows Objects (Services, Filesystem, shared-drive etc) and generate a report in csv which will mailed to respective resolving team for further action. The script check their current status and update the csv file. kup is performed by our Support Team resource.  The script generates the report mentioning the status of Qlikview Services and will be mailed for reference checks.


Functionality:
--------------

The powershell script perform following functionality:

1. Check Windows Server Availability - Ping status
2. Check mapped shared drive offline/ online status
3. Connect with underlying DB2 Database and check the database status - Started/ stopped
3. Check Web-Applicaiton URL to see HTTP Response/ Request status
4. Check Window Services status (Started, Stopped)
5. Connect the AIX Boxes using Putty command to check process running on AIX process or not
6. copy files across windows and AIX system using PSSCP utility
7. Check VB interfaces running on system or not
8. Email the csv file to respective resolver team


Dependency:
-----------

1. CSV File:

Provide a list of server name and respective system objects listed above to be monitored

2. Batchfiles:

Batch file contains path of AIX script which need to be accessed
