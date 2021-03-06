function Get-Five9ColumnNames
{
    <#
    .SYNOPSIS
    
        Function used to returns a list of field names for a specific type of statistic.

    .EXAMPLE
    
        Get-Five9ColumnNames -Type 'AgentState'
    
        # Returns available column names for statistic type AgentState
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
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
        [Parameter(Mandatory=$true)][ValidateSet('AgentState','AgentStatistics','ACDStatus','CampaignState','OutboundCampaignManager','OutboundCampaignStatistics','InboundCampaignStatistics','AutodialCampaignStatistics')][string]$Type
    )

    try
    {

        Test-Five9StatsConnection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning column names for statistic type '$Type'" 

        $response = $Five9StatisticsClient.getColumnNames($Type, $true)

        return $response.values

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
