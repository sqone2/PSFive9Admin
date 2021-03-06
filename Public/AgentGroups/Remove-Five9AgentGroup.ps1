function Remove-Five9AgentGroup
{
    <#
    .SYNOPSIS
    
        Function used to delete an agent group

    .EXAMPLE
    
        Remove-Five9AgentGroup -Name "Team Joe"
    
        # Deletes agent group named "Team Joe"
    
    #>
        [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Name of group being removed
        [Parameter(Mandatory=$true)][string]$Name
    )
    
    try
    {
        Test-Five9Connection -ErrorAction: Stop
       
        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing Five9 agent group '$Name'." 
        $response =  $global:DefaultFive9AdminClient.deleteAgentGroup($Name)

        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}



