function Get-Five9CallVariableGroup
{
    <#
    .SYNOPSIS
    
        Function used to get call variable group(s) from Five9
   
    .EXAMPLE
    
        Get-Five9CallVariableGroup
    
        # Returns all call variable groups
    
    .EXAMPLE
    
        Get-Five9CallVariableGroup -GroupName "Agent"
    
        # Returns call variable group matching group name "Agent"

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Returns only call variable groups matching a given regex string. If omitted, all groups will be returned
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )
    
    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning Five9 call variable group '$NamePattern'." 
        return $global:DefaultFive9AdminClient.getCallVariableGroups($NamePattern) | sort name
    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}
