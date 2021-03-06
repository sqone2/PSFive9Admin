function Get-Five9SkillMember
{
    <#
    .SYNOPSIS
    
        Function used to get the members of a given skill

    .EXAMPLE
    
        Get-Five9SkillMember -Name "MultiMedia"
    
        # Gets members of skill MultiMedia
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Skill Name to get members of
        [Parameter(Mandatory=$true)][string]$Name
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning members of skill '$Name'" 
        $response = $global:DefaultFive9AdminClient.getSkillInfo($Name)

        return $response.users | sort username

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}



