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

Connect to Five9 admin web service

    Connect-Five9AdminWebService

&nbsp;
&nbsp;
### Examples


Get existing user(s):

     Get-Five9User -NamePattern "jdoe@domain.com"

&nbsp;
Creating a new user:

    New-Five9User -DefaultRole Agent -UserProfileName "Agent_Profile" -FirstName "Susan" -LastName "Davis" -UserName sdavis@domain.com -Email sdavis@domain.com -Password Temp1234!

&nbsp;
Create a new skill:

    New-Five9Skill -SkillName "MultiMedia"
    
&nbsp;  
Add new user to new skill:

    Add-Five9SkillMember -Username "sdavis@domain.com" -SkillName "Multimedia"
    
