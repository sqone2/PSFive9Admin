<#
.SYNOPSIS
    
    Function used to create a new user
 
.DESCRIPTION
 
    Function used to create a new user
 
.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "Get-Five9AdminClient" to get SOAP client

.PARAMETER DefaultRole
 
    A new Five9 user must have at least one role, this allows you to pick one to start. Alternatively, use -CopyFromUsername to copy roles from another existing user. To add further roles, use command "Add-Five9UserRole"

.PARAMETER Identity
 
    Username of the user being modified.

.PARAMETER FirstName

    New first name

.PARAMETER LastName

    New last name

.PARAMETER Email

    New email address

.PARAMETER Password

    New password

.PARAMETER FederationId

    New federationId. Used for single-sign-on

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
    
    PSFive9Admin.userGeneralInfo

.NOTES

    Username field is immutable and cannot be changed.

.EXAMPLE
    
    $adminClient = Get-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    Set-Five9User -Five9AdminClient $adminClient -Identity 'jdoe@domain.com' -LastName "Davis"

    # Changes LastName value for user "jdoe@domain.com"


.EXAMPLE
    
    Set-Five9User -Five9AdminClient $adminClient -Identity 'jdoe@domain.com' -Password "Welcome#1" -MustChangePassword $true

    # Sets password and requires change at next logon for user "jdoe@domain.com"



#>
function Set-Five9User
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,

        [Parameter(Mandatory=$true)][string]$Identity,

        [Parameter(Mandatory=$false)][string]$FirstName,
        [Parameter(Mandatory=$false)][string]$LastName,
        [Parameter(Mandatory=$false)][ValidatePattern('^\S{2,}@\S{2,}\.\S{2,}$')][string]$Email,
        [Parameter(Mandatory=$false)][string]$Password,
        [Parameter(Mandatory=$false)][string]$FederationId,
        [Parameter(Mandatory=$false)][bool]$CanChangePassword,
        [Parameter(Mandatory=$false)][bool]$MustChangePassword,
        [Parameter(Mandatory=$false)][bool]$Active,
        
        [Parameter(Mandatory=$false)][string]$UserProfileName,
        
        [Parameter(Mandatory=$false)][dateTime]$StartDate,
        [Parameter(Mandatory=$false)][ValidateLength(4,4)][string]$Extension,
        [Parameter(Mandatory=$false)][string]$PhoneNumber,

        
        [Parameter(Mandatory=$false)][string]$Locale,
        [Parameter(Mandatory=$false)][string]$UnifiedCommunicationId
    )

    try
    {

        $userToModify = $null
        try
        {
            $userToModify = $Five9AdminClient.getUsersGeneralInfo($Identity)
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


        $response = $Five9AdminClient.modifyUser($userToModify, $null, $null)

        return $response.generalInfo

    }
    catch
    {
        throw $_
        return
    }

}



