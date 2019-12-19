[![Build status](https://ci.appveyor.com/api/projects/status/kjkrr2mo550j57mq?svg=true)](https://ci.appveyor.com/project/sqone2/psfive9admin) [![PS Gallery](https://img.shields.io/badge/install-PS%20Gallery-blue.svg)](https://www.powershellgallery.com/packages/PSFive9Admin/)  
&nbsp;

 
 # PSFive9Admin
Powershell functions for working with the Five9 Admin Web Service API
&nbsp;
&nbsp;

&nbsp;
&nbsp;
### Installation

Install and Import module from PowerShell Gallery
       
       Install-Module PSFive9Admin -Force
       
       Import-Module PSFive9Admin
    
&nbsp;
&nbsp;
### Prerequisites

1. Setup a user in your Five9 domain, and grant administrative rights as needed
1. Create web service proxy using `New-Five9AdminClient`. This object will be passed as a parameter to all other functions

		$proxy = New-Five9AdminClient -Username "admin_user@domain.com" -Password "P@ssword!"

&nbsp;
&nbsp;
### Examples


Get existing user(s):

     Get-Five9User -AdminClient $proxy -NamePattern "jdoe@domain.com"
     
     # Returns user matching username "jdoe@domain.com"

&nbsp;
Creating a new user:

    New-Five9User -AdminClient $proxy -DefaultRole Agent -UserProfileName "Agent_Profile" -FirstName "Susan" -LastName "Davis" -UserName sdavis@domain.com -Email sdavis@domain.com -Password Temp1234!

    # Creates a new user with name "Susan Davis"

&nbsp;
Create a new skill:

    New-Five9Skill -AdminClient $proxy -SkillName "MultiMedia"
    
    # Creates a new skill named MultiMedia
    
&nbsp;  
Add new user to new skill:

    Add-Five9SkillMember -AdminClient $proxy -Username "sdavis@domain.com" -SkillName "Multimedia"
    
    # Adds user jdoe@domain.com to skill Multimedia
