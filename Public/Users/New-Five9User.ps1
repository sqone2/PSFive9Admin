function New-Five9User
{
    <#
    .SYNOPSIS
    
        Function used to create a new user

    .EXAMPLE
    
        New-Five9User -CopyRolesFromUsername 'jdoe@domain.com' -FirstName "Susan" -LastName "Davis" -Username sdavis@domain.com -Email sdavis@domain.com -Password Temp1234!

        # Creates a new user Susan Davis. Roles will be copied from existing user "jdoe@domain.com"

    .EXAMPLE
    
        New-Five9User -DefaultRole Agent -FirstName "Susan" -LastName "Davis" -Username sdavis@domain.com -Email sdavis@domain.com -Password Temp1234!

        # Creates a new user Susan Davis. Default Agent role and permissions will be assigned

    .EXAMPLE
    
        New-Five9User -DefaultRole Agent -UserProfileName "Agent_Profile" -FirstName "Susan" -LastName "Davis" -Username sdavis@domain.com -Email sdavis@domain.com -Password Temp1234!

        # Creates a new user Susan Davis. Default Agent role and permissions will be assigned, but roles from User Profile "Agent_Profile" will override this role

    #>
    [CmdletBinding(DefaultParametersetName='DefaultRole', PositionalBinding=$false)] 
    param
    (

        <#
        A new Five9 user must have at least one role, this allows you to pick one to start. 
        Alternatively, use -CopyFromUsername to copy roles from another existing user.

        Options are:
            • Agent
            • Admin
            • Supervisor
            • Reporting
        #>
        [Parameter(ParameterSetName='DefaultRole',Mandatory=$true)][ValidateSet("Agent", "Admin", "Supervisor", "Reporting")][string]$DefaultRole,

        # Used instead of -DefaultRole. This parameter will copy roles from another existing user
        [Parameter(ParameterSetName='CopyRolesFrom',Mandatory=$true)][string]$CopyRolesFromUsername,

        # New user's first name
        [Parameter(Mandatory=$true)][string]$FirstName,

        # New user's last name
        [Parameter(Mandatory=$true)][string]$LastName,

        # New user's username
        [Parameter(Mandatory=$true)][string]$Username,

        # New user's email address
        [Parameter(Mandatory=$true)][ValidatePattern('^\S{2,}@\S{2,}\.\S{2,}$')][string]$Email,

        # New user's password
        [Parameter(Mandatory=$true)][string]$Password,

        # New user's federationId. Used for single-sign-on
        [Parameter(Mandatory=$false)][string]$FederationId,

        # Whether the account is enabled
        [Parameter(Mandatory=$false)][bool]$Active = $true,

        # Whether the user can change their password
        [Parameter(Mandatory=$false)][bool]$CanChangePassword = $true,

        # Requires password change at next logon
        [Parameter(Mandatory=$false)][bool]$MustChangePassword = $true,

        # Profile assigned to user
        [Parameter(Mandatory=$false)][string]$UserProfileName,

        # Date that user stared using Five9. Used in reporting. Will use today's date if omitted.
        [Parameter(Mandatory=$false)][dateTime]$StartDate,

        # User's phone extension. Will be auto-assigned if omitted
        [Parameter(Mandatory=$false)][ValidateLength(1,6)][string]$Extension,

        # One or more skills to be added to new user. Only used when UserProfile is not specified
        [Parameter(Mandatory=$false)][string[]]$Skills,

        # One or more agent groups to be added to new user
        [Parameter(Mandatory=$false)][string[]]$AgentGroups,

        # Phone number of the unified communication user
        [Parameter(Mandatory=$false)][string]$PhoneNumber,

        # User's locale
        [Parameter(Mandatory=$false)][string]$Locale = 'en-US',

        # Unified communication ID, for example, a Skype for Business ID such as syoung@qa59.local.com
        [Parameter(Mandatory=$false)][string]$UnifiedCommunicationId
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $newUserInfo = New-Object -TypeName PSFive9Admin.userInfo

        if ($PsCmdLet.ParameterSetName -eq "CopyRolesFrom")
        {
            $copyFrom = $null
            $copyFrom = $global:DefaultFive9AdminClient.getUsersInfo($CopyRolesFromUsername)

            if ($copyFrom.Count -gt 1)
            {
                throw "Error copying roles from user ""$CopyRolesFromUsername"". Multiple matches were found in Five9 using that username."
                return
            }

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


            $newUserInfo.roles = $userRoles
        }

        $generalInfo = @{
            userName                    = $Username
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
        else
        {
            if ($PSBoundParameters.Keys -contains 'Skills')
            {
                foreach ($skill in $Skills)
                {
                    $newUserInfo.skills += New-Object PSFive9Admin.userSkill -Property @{
                        skillName = $skill
                        userName = $Username
                        level = "1"
                    }
                }
                
            }
        }

        if ($PSBoundParameters.Keys -contains 'AgentGroups')
        {
            $newUserInfo.agentGroups = $AgentGroups
        }

        $newUserInfo.generalInfo = $generalInfo


        Write-Verbose "$($MyInvocation.MyCommand.Name): Creating new user '$Username'." 
        $response = $global:DefaultFive9AdminClient.createUser($newUserInfo)

        return $response
    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
