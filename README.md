# PSFive9Admin
Powershell functions for working with the Five9 Admin Web Service API

Five9 API documentation: https://webapps.five9.com/assets/files/for_customers/documentation/apis/config-webservices-api-reference-guide.pdf

&nbsp;
&nbsp;
### Installation

Download or clone source and copy to a valid module directory. i.e. `C:\Program Files\WindowsPowerShell\Modules\`

From Powershell, import module

    Import-Module PSFive9Admin
    
&nbsp;
&nbsp;
### Prerequisites

1. Setup a user in your Five9 domain which has full Administrative rights
2. Import module

    Import-Module PSFive9Admin
   
    
3. All Powershell functions require a mandatory parameter called `-Five9AdminClient`. Use `New-Five9AdminClient` to create a SOAP proxy which will be reused in all functions.


    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"

    
  
&nbsp;
&nbsp;
### Examples


Get existing user(s):

     Get-Five9User -Five9AdminClient $adminClient -NamePattern "jdoe@domain.com"
     
     # Returns user who matches the string "jdoe@domain.com"


Creating a new user:

    New-Five9User -Five9AdminClient $adminClient -DefaultRole Agent -UserProfileName "Agent_Profile" -FirstName "Susan" -LastName "Davis" -UserName sdavis@domain.com -Email sdavis@domain.com -Password Temp1234!

    # Creates a new user Susan Davis. Default Agent role and permissions will be assigned, but roles from User Profile "Agent_Profile" will override this role


Create a new skill:

    New-Five9Skill -Five9AdminClient $adminClient -SkillName "MultiMedia"
    
    # Creates a new skill named MultiMedia
    
    
Add new user to new skill:

    Add-Five9SkillMember -Five9AdminClient $adminClient -Username "sdavis@domain.com" -SkillName "Multimedia"
    
    # Adds user jdoe@domain.com to skill Multimedia
