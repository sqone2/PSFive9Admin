function Get-Five9AgentGroupMember
{
    <#
    .SYNOPSIS
    
        Function used to get agent group members

    .EXAMPLE
    
        Get-Five9AgentGroupMember -Name "Team Joe"
    
        # Returns members of agent group "Team Joe"
    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Name of agent group whose members will be returned
        [Parameter(Mandatory=$true)][string]$Name
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $response = $global:DefaultFive9AdminClient.getAgentGroups($Name)

        if ($response.Count -gt 1)
        {
            throw "Multiple agent groups were found using query: ""$Name"". Please try using the exact name of the agent group."
            return
        }

        if ($response -eq $null)
        {
            throw "Cannot find a agent group with name: ""$Name"". Remember that Name is case sensitive."
            return
        }

        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning members of agent group '$Name'" 
        return $response.agents

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}
