# PSFive9Admin
Powershell functions for working with the Five9 Admin Web Service API

Five9 API documentation: 
https://webapps.five9.com/assets/files/for_customers/documentation/apis/config-webservices-api-reference-guide.pdf

&nbsp;
&nbsp;
### Installation

1. Download or clone source
1. Copy to a valid module directory. i.e. `C:\Program Files\WindowsPowerShell\Modules\`
1. From Powershell, import module

       Import-Module PSFive9Admin
    
&nbsp;
&nbsp;
### Prerequisites

1. Setup a user in your Five9 domain, and grant administrative rights as needed
1. Create SOAP proxy object using `New-Five9AdminClient`. This SOAP proxy will be passed as a parameter to all other Five9 Admin functions.

		$adminClient = New-Five9AdminClient -Username "admin_user@domain.com" -Password "P@ssword!"

&nbsp;
&nbsp;
### Examples


Get existing user(s):

     Get-Five9User -Five9AdminClient $adminClient -NamePattern "jdoe@domain.com"
     
     # Returns user matching username "jdoe@domain.com"

&nbsp;
Creating a new user:

    New-Five9User -Five9AdminClient $adminClient -DefaultRole Agent -UserProfileName "Agent_Profile" -FirstName "Susan" -LastName "Davis" -UserName sdavis@domain.com -Email sdavis@domain.com -Password Temp1234!

    # Creates a new user Susan Davis

&nbsp;
Create a new skill:

    New-Five9Skill -Five9AdminClient $adminClient -SkillName "MultiMedia"
    
    # Creates a new skill named MultiMedia
    
&nbsp;  
Add new user to new skill:

    Add-Five9SkillMember -Five9AdminClient $adminClient -Username "sdavis@domain.com" -SkillName "Multimedia"
    
    # Adds user jdoe@domain.com to skill Multimedia
