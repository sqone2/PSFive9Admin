<#
.SYNOPSIS
    
    Function used to modify existing call variable

.PARAMETER Name

    Name of existing call variable

.PARAMETER Group

    Group name of existing call variable

.PARAMETER Description

    Description for new call variable

.PARAMETER ApplyToAllDispositions

    If set to $true, variable will be set for all dispositions

.PARAMETER Dispositions

    If -ApplyToAllDispositions is $false, this parameter lists the names of the dispositions for which to set this variable

.PARAMETER Reporting

    Whether to add the values to reports


.PARAMETER DefaultValue

    Optional value that may be assigned to a call variable. For example, a boolean's default value could be set to "True" or "False"
   

.EXAMPLE

    Set-Five9CallVariable -Name "MiddleName" -Group "CustomerVars" -ApplyToAllDispositions $true -Reporting $true

    # Modifies existing call variable named "MiddleName" within the "CustomerVars" call variable group
    
#>

function Set-Five9CallVariable
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Group,
        [Parameter(Mandatory=$false)][string]$Description,
        [Parameter(Mandatory=$false)][bool]$ApplyToAllDispositions,
        [Parameter(Mandatory=$false)][string[]]$Dispositions,
        [Parameter(Mandatory=$false)][bool]$Reporting,
        [Parameter(Mandatory=$false)][string]$DefaultValue
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $callVariableToModify = $null
        try
        {
            $callVariableToModify = $global:DefaultFive9AdminClient.getCallVariables($Name, $Group)
        }
        catch
        {
        
        }


        if ($callVariableToModify -eq $null)
        {
            throw "Cannot find a Call Variable with name: ""$Name"" within the Group ""$Group"". Remember that Name and Group are case sensitive."
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

        Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying call variable '$Name'." 
        $response = $global:DefaultFive9AdminClient.modifyCallVariable($callVariableToModify)
        return $response

    }
    catch
    {
        Write-Error $_
    }
}



