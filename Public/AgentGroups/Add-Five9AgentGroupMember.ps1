function Add-Five9AgentGroupMember
{
    <#
    .SYNOPSIS
    
        Function used to add member(s) to an agent group

    .EXAMPLE
    
        Add-Five9AgentGroupMember -GroupName "Team Joe" -Member "jdoe@domain.com"
    
        # Adds one member to agent group "Team Joe"
    
    .EXAMPLE
    
        Add-Five9AgentGroupMember -GroupName "Team Joe" -Member "jdoe@domain.com", "sdavis@domain.com"
    
        # Adds multiple members to agent group "Team Joe"

    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Name of agent group to add member(s) to
        [Parameter(Mandatory=$true)][Alias('Name')][string]$GroupName,

        # Username of single member, or array of multiple usernames to be added to agent group
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
            throw "Multiple agent groups were found using query: ""$GroupName"". Please try using the exact name of the agent group."
            return
        }

        if ($agentGroupToModify -eq $null)
        {
            throw "Cannot find a agent group with name: ""$GroupName"". Remember that Name is case sensitive."
            return
        }


        Write-Verbose "$($MyInvocation.MyCommand.Name): Adding member(s) to agent group '$GroupName'." 
        $response =  $global:DefaultFive9AdminClient.modifyAgentGroup($agentGroupToModify, $Members, $null)

        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}


