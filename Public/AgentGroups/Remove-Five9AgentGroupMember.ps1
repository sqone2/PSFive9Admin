function Remove-Five9AgentGroupMember
{
    <#
    .SYNOPSIS
    
        Function used to remove member(s) from an agent group

    .EXAMPLE
    
        Remove-Five9AgentGroupMember -GroupName "Team Joe" -Member "jdoe@domain.com"
    
        # Removes one member from agent group "Team Joe"
    
    .EXAMPLE
    
        Remove-Five9AgentGroupMember -GroupName "Team Joe" -Member "jdoe@domain.com", "sdavis@domain.com"
    
        # Removes multiple members from agent group "Team Joe"

    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Name of agent group to remove member(s) from
        [Parameter(Mandatory=$true)][Alias('Name')][string]$GroupName,

        # Username of single member, or array of multiple usernames to be removed from agent group
        [Parameter(Mandatory=$true)][string[]]$Members
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $agentGroupToModify = $null
        try
        {
            $agentGroupToModify = $global:DefaultFive9AdminClient.getAgentGroup($GroupName)
        }
        catch
        {
        
        }

        if ($agentGroupToModify.Count -gt 1)
        {
            throw "Multiple Agent Groups were found using query: ""$GroupName"". Please try using the exact username of the user you're trying to modify."
            return
        }

        if ($agentGroupToModify -eq $null)
        {
            throw "Cannot find a Agent Group with name: ""$GroupName"". Remember that Name is case sensitive."
            return
        }

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing member(s) to agent group '$GroupName'." 
        $response =  $global:DefaultFive9AdminClient.modifyAgentGroup($agentGroupToModify, $null, $Members)

        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}


