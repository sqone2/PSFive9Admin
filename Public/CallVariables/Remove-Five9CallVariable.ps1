function Remove-Five9CallVariable
{
    <#
    .SYNOPSIS
    
        Function used to remove an existing call variable

    .EXAMPLE
    
        Remove-Five9CallVariable -VariableName "SalesforceId" -GroupName "Salesforce"
    
        # Deletes existing call variable named "SalesforceId" which is in the "Salesforce" call variable group

    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Name of existing call variable to be removed
        [Parameter(Mandatory=$true)][Alias('Name')][string]$VariableName,

        # Group name of existing call variable to be removed
        [Parameter(Mandatory=$true)][Alias('Group')][string]$GroupName
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing call variable '$VariableName' within group '$GroupName'." 
        $response = $global:DefaultFive9AdminClient.deleteCallVariable($VariableName, $GroupName)
        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}



