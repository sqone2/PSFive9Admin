function Set-Five9IVRScript
{
    <#
    .SYNOPSIS
    
        Function used to create a new Five9 IVR script

    .EXAMPLE
    
        $script = Get-Five9IVRScript 'Support-Inbound'
        Set-Five9IVRScript -Name 'Sales-Inbound' -Description 'Default Sales Script' -XmlDefinition $script.xmlDefinition
    
        # Modifies IVR script 'Sales-Inbound' using the XML from 'Support-Inbound'
    
    .EXAMPLE
    
        $xml = Get-Content 'C:\Temp\Support-Inbound.five9ivr'
        Set-Five9IVRScript -Name 'Sales-Inbound' -Description 'Default Sales Script' -XmlDefinition $xml

        # Modifies IVR script using XML which has ben previously exported to a file

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Name of IVR script being modified
        [Parameter(Mandatory=$true)][string]$Name,

        # Description of IVR script being modified
        [Parameter(Mandatory=$false)][string]$Description,

        # IVR script data in XML format
        # Specify the text as CDATA, or replace the special characters with their ISO 8859-1 codes
        [Parameter(Mandatory=$false)][object]$XmlDefinition
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        if ($PSBoundParameters.Keys -contains 'Description' -or $PSBoundParameters.Keys -contains 'XmlDefinition')
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Updating IVR script '$Name'."

            $ivrScriptDef = New-Object -TypeName PSFive9Admin.ivrScriptDef 
            $ivrScriptDef.name = $Name

            if ($PSBoundParameters.Keys -contains 'Description')
            {
                $ivrScriptDef.description = $Description
            }

            if ($PSBoundParameters.Keys -contains 'XmlDefinition')
            {
                $ivrScriptDef.xmlDefinition = $XmlDefinition | Out-String
            }

            $global:DefaultFive9AdminClient.modifyIVRScript($ivrScriptDef)

        }

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}
