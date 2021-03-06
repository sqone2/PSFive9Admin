function Remove-Five9Skill
{
    <#
    .SYNOPSIS
    
        Function used to delete a skill
   
    .EXAMPLE
    
        Remove-Five9Skill -Name "MultiMedia"
    
        # Deletes skill named MultiMedia
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Skill name to be deleted
        [Parameter(Mandatory=$true)][string]$Name
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing skill '$Name'." 
        $response = $global:DefaultFive9AdminClient.deleteSkill($Name)

        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
