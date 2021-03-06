function Get-Five9IVRScript
{
    <#
    .SYNOPSIS
    
        Function used to return Five9 IVR script(s)

    .EXAMPLE
    
        Get-Five9IVRScript
    
        # Returns all IVR scripts
    
    .EXAMPLE
    
        Get-Five9IVRScript -NamePattern "Sales-IVR-Script"
    
        # Returns IVR scripts that matches the string "Sales-IVR-Script"

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Optional regex parameter. If used, function will return only IVR scripts matching regex string
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop


        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning IVR script(s) matching pattern '$($NamePattern)'."
        $response = $global:DefaultFive9AdminClient.getIVRScripts($NamePattern) | sort name

        return $response


    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}


