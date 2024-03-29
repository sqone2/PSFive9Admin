function Remove-Five9CallVariableGroup
{
    <#
    .SYNOPSIS
    
        Function used to remove an existing call variable group

    .EXAMPLE
    
        Remove-Five9CallVariableGroup -Name Salesforce -Description
    
        # Deletes existing call variable group named "Salesforce"

    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Name of existing call variable group to be removed
        [Parameter(Mandatory=$true)][string]$Name
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop
       
        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing call variable group '$Name'." 
        $response = $global:DefaultFive9AdminClient.deleteCallVariablesGroup($Name)

        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}
