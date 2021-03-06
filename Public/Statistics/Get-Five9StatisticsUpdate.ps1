function Get-Five9StatisticsUpdate
{
    <#
    .SYNOPSIS
    
        Returns changes in the statistics

    .EXAMPLE
    
        $campaignStats = Get-Five9Statistics -Type 'CampaignState'
        $campaignStats = $campaignStats | Get-Five9StatisticsUpdate
    
        # Returns CampaignState statistics using Get-Five9Statistics and then refreshes the data
    
    .EXAMPLE
        #
        # get CampaignState statistics
        $campaignStats = Get-Five9Statistics -Type 'CampaignState'

        # display output
        Clear-Host
        $campaignStats.data | ft

        # endless loop
        while ($true)
        {
            # update statistics
            $update = $campaignStats | Get-Five9StatisticsUpdate

            if ($update -ne $null)
            {
                # if there is a change, display new output
                Clear-Host
                $campaignStats = $update
                $campaignStats.data | ft
            }

        }
    
        # Example of how to show stats in real time by calling Get-Five9StatisticsUpdate in a loop

    #>
    [CmdletBinding(DefaultParametersetName='MergeUpdate',PositionalBinding=$false)]
    param
    (
        # Object returned from calling either Get-Five9Statistics or Get-Five9StatisticsUpdate
        [Parameter(ParameterSetName='MergeUpdate',Mandatory=$true,ValueFromPipeline=$true,Position=0)][statisticOutput]$StatisticOutput,

        # Whether the update is merged with the StatisticOutput object
        [Parameter(ParameterSetName='MergeUpdate',Mandatory=$false)][bool]$MergeUpdate = $true,

        <#
        Statistic Type

        Options are:
            • AgentState
            • AgentStatistics
            • ACDStatus
            • CampaignState
            • OutboundCampaignManager
            • OutboundCampaignStatistics
            • InboundCampaignStatistics
            • AutodialCampaignStatistics
        #>
        [Parameter(ParameterSetName='UpdateOnly',Mandatory=$true)][ValidateSet('AgentState','AgentStatistics','ACDStatus','CampaignState','OutboundCampaignManager','OutboundCampaignStatistics','InboundCampaignStatistics','AutodialCampaignStatistics')][string]$Type,
        
        # Time of the previous update. Epoch time in milliseconds
        [Parameter(ParameterSetName='UpdateOnly',Mandatory=$true)][string]$LastTimeStamp,
        
        <#
        Number of milliseconds to wait before closing the connection when no changes occur. 
        The system sends you event notifications whether or not the LongPollingTimeout interval times out. 
        If a state changes, the system does not wait for the longPollingTimeout interval to end. 
        Instead, you will receive an event notification immediately after the state changes. 
        Therefore, Five9 recommends not setting the longPollingTimeout interval to a very low value.

        If omitted, the default value of 5000 (5 seconds) will be used.
        #>
        [Parameter(Mandatory=$false)][int]$LongPollingTimeout = 5000,

        # Whether to show only the current user’s queues
        [Parameter(Mandatory=$false)][bool]$ShowOnlyMySkills = $false

    )

    try
    {

        Test-Five9StatsConnection -ErrorAction: Stop

        if ($PsCmdLet.ParameterSetName -eq "MergeUpdate")
        {
            if ($StatisticOutput.type.Length -lt 2)
            {
                throw "Invalid value for parameter -StatisticOutput."
            }

            $update = $Five9StatisticsClient.getStatisticsUpdate($StatisticOutput.type, $true, $StatisticOutput.timestamp, $LongPollingTimeout, $ShowOnlyMySkills, $true)

            if ($MergeUpdate -eq $false)
            {
                Write-Verbose "$($MyInvocation.MyCommand.Name): Returning updates for '$Type'." 
                return $update
            }

            if ($update -eq $null)
            {
                Write-Verbose "$($MyInvocation.MyCommand.Name): No changes to statistic data since last poll."

                return $null
            }

            $newOutput = New-Object statisticOutput -Property @{
                type = $update.type
                timestamp = $update.lastTimestamp
                data = $StatisticOutput.data
            }

            $objectMap = @{
                'AgentState' = 'Username'
                'AgentStatistics' = 'Username'
                'ACDStatus' = 'Skill Name'
                'CampaignState' = 'Campaign Name'
                'OutboundCampaignManager' = 'Campaign Name'
                'OutboundCampaignStatistics' = 'Campaign Name'
                'InboundCampaignStatistics' = 'Campaign Name'
                'AutodialCampaignStatistics' = 'Campaign Name'

            }

            $primaryObj = $objectMap[$newOutput.type]

            if ($primaryObj -eq $null)
            {
                throw "Error processing statistics update. Invalid statistic type '$($newOutput.type)'."
            }

            # add items
            if ($update.addedObjects.values.Count -gt 0)
            {
                foreach ($addItem in $update.addedObjects.values)
                {
                    $newOutput.data += New-Object psobject -Property @{
                        $primaryObj = $addItem
                    }
                }
            }


            # update items
            foreach ($updateItem in $update.dataUpdate)
            {
                $rowToUpdate = $null
                $rowToUpdate = $newOutput.data | ? {$_.$primaryObj -eq $updateItem.objectName}

                $rowToUpdate | Add-Member -MemberType: NoteProperty -Name $updateItem.columnName -Value $updateItem.columnValue -Force

            }

            # remove items
            if ($update.deletedObjects.values.Count -gt 0)
            {
                $newOutput.data = $newOutput.data | ? {$_.$primaryObj -ne $update.deletedObjects.values}
            }
            

            Write-Verbose "$($MyInvocation.MyCommand.Name): Returning merged updates for '$Type'." 

            return $newOutput
        }


        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning updates for '$Type'." 
        $update = $Five9StatisticsClient.getStatisticsUpdate($Type, $true, $LastTimeStamp, $LongPollingTimeout, $ShowOnlyMySkills, $true)

        return $update

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
