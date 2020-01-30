function Remove-Five9UserProfileMember
{
    <#
    .SYNOPSIS
    
        Function used to remove a member to an existing user profile

    .EXAMPLE
    
        Remove-Five9UserProfileMember -Name "Sales-Profile" -Username "jdoe@domain.com"
    
        # Removes user jdoe@domain.com from user profile Sales-Profile

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Name of user profile being modified
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # Username of user being removed from user profile
        [Parameter(Mandatory=$true, Position=1)][string]$Username
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing user '$Username' to user profile '$Name'." 
        $response = $global:DefaultFive9AdminClient.modifyUserProfileUserList($Name, $null, $Username)

        return $response

    }
    catch
    {
        throw $_
    }
}



