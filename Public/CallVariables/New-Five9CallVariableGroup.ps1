function New-Five9CallVariableGroup
{

    <#
    .SYNOPSIS
    
        Function used to create a new call variable group

    .EXAMPLE
    
        New-Five9CallVariableGroup -GroupName Salesforce -Description "Call variables used for Salesforce reporting"
    
        # Creates new call variable group named "Salesforce". 
        # Use New-Five9CallVariable to create a variable and add it to your new group

    #>

    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # Name for new call variable group
        [Parameter(Position=0,Mandatory=$true)][Alias('Name')][string]$GroupName,

        # Description for new call variable group
        [Parameter(Mandatory=$false)][string]$Description
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Creating new call variable group '$GroupName'." 
        $response = $global:DefaultFive9AdminClient.createCallVariablesGroup($GroupName, $Description)

        return $response
    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}
