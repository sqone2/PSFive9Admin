function Set-Five9User
{
    <#
    .SYNOPSIS
    
        Function used to create a new user

    .NOTES

        Username field is immutable and cannot be changed.

    .EXAMPLE
    
        Set-Five9User -Identity 'jdoe@domain.com' -LastName "Davis"

        # Changes LastName value for user "jdoe@domain.com"

    .EXAMPLE
    
        Set-Five9User -Identity 'jdoe@domain.com' -Password "Welcome#1" -MustChangePassword $true

        # Sets password and requires change at next logon for user "jdoe@domain.com"

    .LINK

        Set-Five9User
        Set-Five9MediaType
        Add-Five9Role
        Remove-Five9Role

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Username of the user being modified.
        [Parameter(Mandatory=$true, Position=0)][string]$Identity,

        # New first name
        [Parameter(Mandatory=$false)][string]$FirstName,

        # New last name
        [Parameter(Mandatory=$false)][string]$LastName,

        # New email address
        [Parameter(Mandatory=$false)][ValidatePattern('^\S{2,}@\S{2,}\.\S{2,}$')][string]$Email,

        # New password
        [Parameter(Mandatory=$false)][string]$Password,

        # New federationId. Used for single-sign-on
        [Parameter(Mandatory=$false)][string]$FederationId,

        # Whether the account is enabled
        [Parameter(Mandatory=$false)][bool]$Active,

        # Whether the user can change their password
        [Parameter(Mandatory=$false)][bool]$CanChangePassword,

        # Requires password change at next logon
        [Parameter(Mandatory=$false)][bool]$MustChangePassword,

        # Profile assigned to user
        [Parameter(Mandatory=$false)][string]$UserProfileName,
        
        # Date that user stared using Five9. Used in reporting
        [Parameter(Mandatory=$false)][dateTime]$StartDate,

        # User's phone extension
        [Parameter(Mandatory=$false)][ValidateLength(1,6)][string]$Extension,

        # Phone number of the unified communication user
        [Parameter(Mandatory=$false)][string]$PhoneNumber,

        # User's locale
        [Parameter(Mandatory=$false)][string]$Locale,

        # Unified communication ID, for example, a Skype for Business ID such as syoung@qa59.local.com
        [Parameter(Mandatory=$false)][string]$UnifiedCommunicationId
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $userToModify = $null
        try
        {
            $userToModify = $global:DefaultFive9AdminClient.getUsersGeneralInfo($Identity)
        }
        catch
        {

        }

        if ($userToModify.Count -gt 1)
        {
            throw "Multiple user matches were found using query: ""$Identity"". Please try using the exact username of the user you're trying to modify."
            return
        }

        if ($userToModify -eq $null)
        {
            throw "Cannot find a Five9 user with username: ""$Identity"". Remember that username is case sensitive."
            return
        }


        $userToModify = $userToModify | Select-Object -First 1


        if ($PSBoundParameters.Keys -contains "FirstName")
        {
            $userToModify.firstName = $FirstName
        }

        if ($PSBoundParameters.Keys -contains "LastName")
        {
            $userToModify.lastName = $LastName
        }

        if ($PSBoundParameters.Keys -contains "Email")
        {
            $userToModify.EMail = $Email
        }

        if ($PSBoundParameters.Keys -contains "Password")
        {
            $userToModify.password = $Password
        }

        if ($PSBoundParameters.Keys -contains "FederationId")
        {
            $userToModify.federationId = $FederationId
        }

        if ($PSBoundParameters.Keys -contains "CanChangePassword")
        {
            $userToModify.canChangePasswordSpecified = $true
            $userToModify.canChangePassword = $CanChangePassword
        }

        if ($PSBoundParameters.Keys -contains "MustChangePassword")
        {
            $userToModify.mustChangePasswordSpecified = $true
            $userToModify.mustChangePassword = $MustChangePassword
        }

        if ($PSBoundParameters.Keys -contains "Active")
        {
            $userToModify.active = $Active
        }

        if ($PSBoundParameters.Keys -contains "UserProfileName")
        {
            $userToModify.userProfileName = $UserProfileName
        }

        if ($PSBoundParameters.Keys -contains "StartDate")
        {
            $userToModify.startDate = $StartDate
        }

        if ($PSBoundParameters.Keys -contains "Extension")
        {
            $userToModify.extension = $Extension
        }

        if ($PSBoundParameters.Keys -contains "PhoneNumber")
        {
            $userToModify.phoneNumber = $PhoneNumber
        }

        if ($PSBoundParameters.Keys -contains "Locale")
        {
            $userToModify.locale = $Locale
        }

        if ($PSBoundParameters.Keys -contains "UnifiedCommunicationId")
        {
            $userToModify.unifiedCommunicationId = $UnifiedCommunicationId
        }

        Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying user '$Identity'." 
        $response = $global:DefaultFive9AdminClient.modifyUser($userToModify, $null, $null)

        return $response.generalInfo

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
