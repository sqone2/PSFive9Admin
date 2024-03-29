function Set-Five9CallVariableGroup
{
    <#
    .SYNOPSIS
    
        Function used to modify an existing agent group

    .NOTES

        This function can ONLY update the description value on an existing call variable group. Cannot change name.
   
    .EXAMPLE
    
        Set-Five9CallVariableGroup -GroupName "Salesforce" -Description "New description here"
    
        # Updates description on call variable group "Salesforce"
    #>

    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        # Name of existing call variable group. Case sensitive. (Not possible to change Name using API. Must use GUI)
        [Parameter(Mandatory=$true, Position=0)][Alias('Name')][string]$GroupName,

        # New description value for existing agent group
        [Parameter(Mandatory=$true)][string]$Description
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $callVariableGroupToModify = $null
        try
        {
            $callVariableGroupToModify = $global:DefaultFive9AdminClient.getCallVariableGroups($GroupName)
        }
        catch
        {
        
        }

        if ($callVariableGroupToModify.Count -gt 1)
        {
            throw "Multiple Call Variable Groups were found using query: ""$GroupName"". Please try using the exact username of the user you're trying to modify."
            return
        }

        if ($callVariableGroupToModify -eq $null)
        {
            throw "Cannot find a Call Variable Groups with name: ""$GroupName"". Remember that Name is case sensitive."
            return
        }


        Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying call variable group '$($GroupName)'." 
        $response =  $global:DefaultFive9AdminClient.modifyCallVariablesGroup($GroupName, $Description)

        return $response
    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}



