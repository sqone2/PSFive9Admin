function Reset-Five9CampaignDispositions
{
    <#
    .SYNOPSIS
    
        Function to reset a campaign to redial every number, except for numbers on the Do-Not-Call list
 
    .EXAMPLE
    
        Reset-Five9Campaign -Name 'Hot-Leads'

        # Resets campaign named 'Hot-Leads'

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Campaign name to be reset
        [Parameter(Mandatory=$true)][string]$Name
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Resetting dispostions on campaign '$Name'." 
        return $global:DefaultFive9AdminClient.resetCampaignDispositions($Name)

    }
    catch
    {
        Write-Error $_
    }

}
