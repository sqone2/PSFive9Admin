function Get-Five9CallVariable
{
    <#
    .SYNOPSIS
    
        Function used to get call variable(s) from Five9

    .EXAMPLE
    
        Get-Five9CallVariable
    
        # Returns all call variables

    .EXAMPLE
    
        Get-Five9CallVariable -Group "Call"
    
        # Returns call variables within group "Call"

    .EXAMPLE
    
        Get-Five9CallVariable -Group "Call" -Name "ANI"
    
        # Returns call variable "ANI" within group "Call"
    
    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Group name of existing call variable
        [Parameter(Mandatory=$false)][string]$Group,

        # Name of existing call variable
        [Parameter(Mandatory=$false)][string]$Name
    )
    
    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $callVars = $null

        # return all variables
        if ($PSBoundParameters.Keys -notcontains 'Name' -and $PSBoundParameters.Keys -notcontains 'Group')
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Returning all Five9 call variables." 
            $callVarGroups = $global:DefaultFive9AdminClient.getCallVariableGroups('.*')
            $callVars = $callVarGroups.variables | ? {$_.group -ne $null}

        }
        # return single group
        elseif ($PSBoundParameters.Keys -contains "Group" -and $PSBoundParameters.Keys -notcontains "Name")
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Returning Five9 call variable group '$Group'." 
            $callVarGroup = $global:DefaultFive9AdminClient.getCallVariableGroups($Group) | sort name
            $callVars = $callVarGroup.variables | ? {$_.group -ne $null}
        }
        elseif ($PSBoundParameters.Keys -contains "Name" -and $PSBoundParameters.Keys -notcontains "Group")
        {
            throw "You must specify the -Group parameter when using -Name."
            return
        }
        # return single var
        else
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Returning Five9 call variable '$Name' within group '$Group'." 
            $callVars = $global:DefaultFive9AdminClient.getCallVariables($Name, $Group)
        }
        

        if ($callVars -ne $null)
        {
            foreach ($var in $callVars)
            {
                try
                {
                    if ($var.group -match 'Call|Agent|IVR|Omni|Customer')
                    {
                        $var | Add-Member -MemberType: NoteProperty -Name category -Value "Default" -Force -ErrorAction: SilentlyContinue
                    }
                    else
                    {
                        $var | Add-Member -MemberType: NoteProperty -Name category -Value "Custom" -Force  -ErrorAction: SilentlyContinue
                    }
                }
                catch
                {
                    return $var
                }
            }

            return $callVars | sort category,group,name
        }

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }
}



