function Set-Five9CallVariable
{
    <#
    .SYNOPSIS
    
        Function used to modify existing call variable

    .EXAMPLE

        Set-Five9CallVariable -VariableName "MiddleName" -GroupName "CustomerVars" -ApplyToAllDispositions $true -Reporting $true

        # Modifies existing call variable named "MiddleName" within the "CustomerVars" call variable group
    
    #>

    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # Name of existing call variable
        [Parameter(Mandatory=$true, Position=0)][Alias('Name')][string]$VariableName,

        # Group name of existing call variable
        [Parameter(Mandatory=$true, Position=1)][Alias('Group')][string]$GroupName,

        # Description for new call variable
        [Parameter(Mandatory=$false)][string]$Description,

        # If set to $true, variable will be set for all dispositions
        [Parameter(Mandatory=$false)][bool]$ApplyToAllDispositions,

        # If -ApplyToAllDispositions is $false, this parameter lists the names of the dispositions for which to set this variable
        [Parameter(Mandatory=$false)][string[]]$Dispositions,

        # Whether to add the values to reports
        [Parameter(Mandatory=$false)][bool]$Reporting,

        # Default initial value assigned to call variable
        [Parameter(Mandatory=$false)][string]$DefaultValue
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $callVariableToModify = $null
        try
        {
            $callVariableToModify = $global:DefaultFive9AdminClient.getCallVariables($VariableName, $GroupName)
        }
        catch
        {
        
        }

        if ($callVariableToModify -eq $null)
        {
            throw "Cannot find a Call Variable with name: ""$VariableName"" within the Group ""$GroupName"". Remember that VariableName and GroupName are case sensitive."
            return
        }

        $callVariableToModify = $callVariableToModify | select -First 1


        if ($PSBoundParameters.Keys -contains "Description")
        {
            $callVariableToModify.description = $Description
        }

        if ($PSBoundParameters.Keys -contains "ApplyToAllDispositions")
        {
            $callVariableToModify.applyToAllDispositions = $ApplyToAllDispositions
            $callVariableToModify.applyToAllDispositionsSpecified = $true
        }
    
        if ($PSBoundParameters.Keys -contains "ApplyToAllDispositions")
        {
            $callVariableToModify.applyToAllDispositions = $ApplyToAllDispositions
            $callVariableToModify.applyToAllDispositionsSpecified = $true
        }

        if ($callVariableToModify.applyToAllDispositions -eq $false)
        {
            if ($PSBoundParameters.Keys -contains "Dispositions")
            {
                $callVariableToModify.dispositions = $Dispositions
            }
        }

        if ($PSBoundParameters.Keys -contains "Reporting")
        {
            $callVariableToModify.reporting = $Reporting
            $callVariableToModify.reportingSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains "DefaultValue")
        {
            $callVariableToModify.defaultValue = $DefaultValue
        
        }

        Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying call variable '$VariableName' within group '$GroupName'." 
        $response = $global:DefaultFive9AdminClient.modifyCallVariable($callVariableToModify)
        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}



