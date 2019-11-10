<#
.SYNOPSIS
    
    Function used to create a new user
 
.DESCRIPTION
 
    Function used to create a new user
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client

.PARAMETER DefaultRole
 
    A new Five9 user must have at least one role, this allows you to pick one to start. Alternatively, use -CopyFromUsername to copy roles from another existing user. To add further roles, use command "Add-Five9UserRole"

.PARAMETER CopyFromUsername
 
    Used instead of -DefaultRole. This parameter will copy roles from another existing user. To add further roles, use command "Add-Five9UserRole"

.PARAMETER FirstName

    New user's first name

.PARAMETER LastName

    New user's last name

.PARAMETER UserName

    New user's username

.PARAMETER Email

    new user's email address

.PARAMETER Password

    New user's password

.PARAMETER FederationId

    New user's federationId. Used for single-sign-on

.PARAMETER CanChangePassword

    Whether the user can change their password

.PARAMETER MustChangePassword 

    Requires password change at next logon

.PARAMETER Active   

    Whether the account is enabled

.PARAMETER UserProfileName  

    Profile assigned to user

.PARAMETER StartDate

    Date that user stared using Five9. Used in reporting. Will use today's date if omitted.

.PARAMETER Extension

    User's phone extension. Will be auto-assigned if omitted

.PARAMETER PhoneNumber

    Phone number of the unified communication user

.PARAMETER Locale

    User's locale

.PARAMETER UnifiedCommunicationId

    Unified communication ID, for example, a Skype for Business ID such as syoung@qa59.local.com

.OUTPUTS
    
    PSFive9Admin.userInfo


.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    New-Five9User -Five9AdminClient $adminClient -CopyRolesFromUsername 'jdoe@domain.com' -FirstName "Susan" -LastName "Davis" -UserName sdavis@domain.com -Email sdavis@domain.com -Password Temp1234!

    # Creates a new user Susan Davis. Roles will be copied from existing user "jdoe@domain.com"

.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    New-Five9User -Five9AdminClient $adminClient -DefaultRole Agent -FirstName "Susan" -LastName "Davis" -UserName sdavis@domain.com -Email sdavis@domain.com -Password Temp1234!

    # Creates a new user Susan Davis. Default Agent role and permissions will be assigned

.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    New-Five9User -Five9AdminClient $adminClient -DefaultRole Agent -UserProfileName "Agent_Profile" -FirstName "Susan" -LastName "Davis" -UserName sdavis@domain.com -Email sdavis@domain.com -Password Temp1234!

    # Creates a new user Susan Davis. Default Agent role and permissions will be assigned, but roles from User Profile "Agent_Profile" will override this role
    

#>
function New-Five9User
{

    [CmdletBinding(DefaultParametersetName='DefaultRole')] 
    param
    (
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,

        [Parameter(ParameterSetName='DefaultRole',Mandatory=$true)][ValidateSet("Agent", "Admin", "Supervisor", "Reporting")][string]$DefaultRole,
        [Parameter(ParameterSetName='CopyRolesFrom',Mandatory=$true)][ValidatePattern('^\S{2,}@\S{2,}\.\S{2,}$')][string]$CopyRolesFromUsername,

        [Parameter(Mandatory=$true)][string]$FirstName,
        [Parameter(Mandatory=$true)][string]$LastName,
        [Parameter(Mandatory=$true)][string]$UserName,
        [Parameter(Mandatory=$true)][ValidatePattern('^\S{2,}@\S{2,}\.\S{2,}$')][string]$Email,
        [Parameter(Mandatory=$true)][string]$Password,

        [Parameter(Mandatory=$false)][string]$FederationId,
        [Parameter(Mandatory=$false)][bool]$CanChangePassword = $true,
        [Parameter(Mandatory=$false)][bool]$MustChangePassword = $true,
        [Parameter(Mandatory=$false)][bool]$Active = $true,
        
        [Parameter(Mandatory=$false)][string]$UserProfileName,
        
        [Parameter(Mandatory=$false)][dateTime]$StartDate,
        [Parameter(Mandatory=$false)][ValidateLength(4,4)][string]$Extension,
        [Parameter(Mandatory=$false)][string]$PhoneNumber,

        
        [Parameter(Mandatory=$false)][string]$Locale = 'en-US',
        [Parameter(Mandatory=$false)][string]$UnifiedCommunicationId
    )

    try
    {
        $newUserInfo = New-Object -TypeName PSFive9Admin.userInfo

        if ($PsCmdLet.ParameterSetName -eq "CopyRolesFrom")
        {
            $copyFrom = $null
            $copyFrom = Get-Five9User -Five9AdminClient $Five9AdminClient -NamePattern $CopyRolesFromUsername

            if ($copyFrom -eq $null)
            {
                throw "Error copying roles from user ""$CopyRolesFromUsername"". User could not be found. Remember that username is case sensitive."
                return
            }

            if ($copyFrom.roles.admin -ne $null)
            {
                $copyFrom.roles.admin = $copyFrom.roles.admin | ? {$_.type -ne "AccessBillingApplication"}
            }

            $newUserInfo.roles += $copyFrom.roles

        }
        else
        {
            
            $userRoles = New-Object -TypeName PSFive9Admin.userRoles

            if ($DefaultRole -eq "Agent")
            {
                $agentRole = New-Object -TypeName PSFive9Admin.agentRole
                $agentRole.alwaysRecorded
                $agentRole.alwaysRecorded = $false
                $agentRole.attachVmToEmail = $false
                $agentRole.sendEmailOnVm = $false
                $agentRole.permissions = @()

                $userRoles.agent = $agentRole

            }
            elseif ($DefaultRole -eq "Admin")
            {
                $userRoles.admin = @()
            }
            elseif ($DefaultRole -eq "Supervisor")
            {
                $userRoles.supervisor = @()
            }
            elseif ($DefaultRole -eq "Reporting")
            {
                $userRoles.reporting = @()
            }
        }

        $newUserInfo.roles = $userRoles



        $generalInfo = @{
            userName                    = $UserName
            EMail                       = $Email
            federationId                = $FederationId
            firstName                   = $FirstName
            lastName                    = $LastName
            password                    = $Password

            activeSpecified             = $true
            active                      = $Active
        
            canChangePasswordSpecified  = $true
            canChangePassword           = $CanChangePassword
        
            mustChangePasswordSpecified = $true
            mustChangePassword          = $MustChangePassword
        
            startDateSpecified          = $true
            startDate                   = $([datetime]::Now)

            locale = $Locale
            unifiedCommunicationId = $UnifiedCommunicationId
        
            phoneNumber = $PhoneNumber
        }


        if ($StartDate -ne $null)
        {
            $generalInfo.startDate = $StartDate
        }

        if ($Extension.Length -gt 0)
        {
            $generalInfo += @{extension = $Extension}
        }

        if ($UserProfileName.Length -gt 0)
        {
            $generalInfo += @{userProfileName = $UserProfileName}
        }

        $newUserInfo.generalInfo = $generalInfo


        $newUserInfo.agentGroups = $AgentGroups
        $newUserInfo.skills = $Skills

        $response = $Five9AdminClient.createUser($newUserInfo)

        return $response
    }
    catch
    {
        throw $_
        return
    }

}
