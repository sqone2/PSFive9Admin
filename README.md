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

Install NuGet (if not already installed)

    Install-PackageProvider NuGet -Force
    Import-PackageProvider NuGet -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    
Set-ExecutionPolicy -ExecutionPolicy: RemoteSigned

Connect to Five9 admin web service

    Connect-Five9AdminWebService

&nbsp;
&nbsp;
### Examples


Get existing user:

     Get-Five9User -NamePattern "jdoe@domain.com"

&nbsp;
Create a new user:

    New-Five9User -DefaultRole Agent -FirstName "Susan" -LastName "Davis" -UserName sdavis@domain.com -Email sdavis@domain.com -Password 'P@ssword!'

&nbsp;
Create a new skill:

    New-Five9Skill -Name "MultiMedia"
    
&nbsp;  
Add new user to new skill:

    Add-Five9SkillMember -Name "Multimedia" -Username "sdavis@domain.com"
    
