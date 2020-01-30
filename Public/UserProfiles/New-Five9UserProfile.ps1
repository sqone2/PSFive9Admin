function New-Five9UserProfile
{
    <#
    .SYNOPSIS
    
        Function used to create a new user profile

    .EXAMPLE
    
        New-Five9UserProfile -Name "Agent-Profile"

        # Creates new user profile and sets agent as the default role

    .EXAMPLE
    
        New-Five9UserProfile -Name "Admin-Profile" -DefaultRole: Admin -Description "Profile for administrators"

        # Creates new user profile and sets admin as the default role


    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Name of new profile
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # Description of new profile
        [Parameter(Mandatory=$false)][string]$Description,

        <#
        A new Five9 user profile must have at least one role, this allows you to pick one to start
        
        Options are:
            • Agent (Default)
            • Admin
            • Supervisor
            • Reporting
        #>
        [Parameter(Mandatory=$false)][ValidateSet("Agent", "Admin", "Supervisor", "Reporting")][string]$DefaultRole = "Agent",

        # Locale of new profile
        [Parameter(Mandatory=$false)][string]$Locale = 'en-US'

    )

    try
    {

        Test-Five9Connection -ErrorAction: Stop


        $newProfile = New-Object PSFive9Admin.userProfile

        $newProfile.name = $Name
        $newProfile.description = $Description
        $newProfile.locale = $Locale

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

        $newProfile.roles = $userRoles

        Write-Verbose "$($MyInvocation.MyCommand.Name): Creating new user profile '$Name'" 
        return $global:DefaultFive9AdminClient.createUserProfile($newProfile)

    }
    catch
    {
        throw $_
    }
}
