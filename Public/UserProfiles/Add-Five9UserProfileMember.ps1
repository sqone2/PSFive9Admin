function Add-Five9UserProfileMember
{
    <#
    .SYNOPSIS
    
        Function used to add a member to an existing user profile

    .EXAMPLE
    
        Add-Five9UserProfileMember -ProfileName "Sales-Profile" -Username "jdoe@domain.com"
    
        # Adds user jdoe@domain.com to user profile Sales-Profile

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Name of user profile being modified
        [Parameter(Mandatory=$true, Position=0)][Alias('Name')][string]$ProfileName,

        # Username of user being added to user profile
        [Parameter(Mandatory=$true, Position=1)][string]$Username
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Adding user '$Username' to user profile '$ProfileName'." 
        $response = $global:DefaultFive9AdminClient.modifyUserProfileUserList($ProfileName, $Username, $null)

        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}



