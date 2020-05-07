[![Build status](https://ci.appveyor.com/api/projects/status/kjkrr2mo550j57mq?svg=true)](https://ci.appveyor.com/project/sqone2/psfive9admin) [![PS Gallery](https://img.shields.io/badge/install-PS%20Gallery-blue.svg)](https://www.powershellgallery.com/packages/PSFive9Admin/)  
&nbsp;

 
 # PSFive9Admin
Powershell functions for working with the Five9 Admin Web Service API
&nbsp;
&nbsp;
#
&nbsp;

### Prerequisites

    # Force TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Install NuGet
    Install-PackageProvider NuGet -Scope: CurrentUser -Force
    Import-PackageProvider NuGet -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

### Install and Connect

    # Install PSFive9Admin module
    Install-Module PSFive9Admin -Scope: CurrentUser -Force
    Import-Module PSFive9Admin

    # Connect to a Five9 domain
    Connect-Five9AdminWebService -Verbose

# 


&nbsp;
### Examples

&nbsp;
![Examples](https://github.com/sqone2/PSFive9Admin/blob/master/assets/psfive9admin-example.png)
&nbsp;

#

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
    
