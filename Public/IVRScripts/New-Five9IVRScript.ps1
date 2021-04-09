function New-Five9IVRScript
{
    <#
    .SYNOPSIS
    
        Function used to create a new Five9 IVR script

    .EXAMPLE
    
        $script = Get-Five9IVRScript 'Support-Inbound'
        New-Five9IVRScript -Name 'Sales-Inbound' -Description 'Default Sales Script' -XmlDefinition $script.xmlDefinition
    
        # Creates new IVR script 'Sales-Inbound' using the XML from 'Support-Inbound'
    
    .EXAMPLE
    
        $xml = Get-Content 'C:\Temp\Support-Inbound.five9ivr'
        New-Five9IVRScript -Name 'Sales-Inbound' -Description 'Default Sales Script' -XmlDefinition $xml

        # Creates new IVR script using XML which has ben previously exported to a file

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Name of new IVR script being created
        [Parameter(Mandatory=$true)][string]$Name,

        # Description of new IVR script being created
        [Parameter(Mandatory=$false)][string]$Description,

        # IVR script data in XML format
        # Specify the text as CDATA, or replace the special characters with their ISO 8859-1 codes
        [Parameter(Mandatory=$true)][object]$XmlDefinition
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop


        Write-Verbose "$($MyInvocation.MyCommand.Name): Creating new IVR script '$Name'."

        $new = $global:DefaultFive9AdminClient.createIVRScript($Name)

        $ivrScriptDef = New-Object -TypeName PSFive9Admin.ivrScriptDef 
        $ivrScriptDef.name = $Name

        if ($PSBoundParameters.Keys -contains 'Description')
        {
            $ivrScriptDef.description = $Description
        }

        $ivrScriptDef.xmlDefinition = $XmlDefinition | Out-String

        Write-Verbose "$($MyInvocation.MyCommand.Name): Uploading XmlDefinition to new IVR script '$Name'."
        $global:DefaultFive9AdminClient.modifyIVRScript($ivrScriptDef)

    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}


