function Get-FileMetadata
{
    <#
    .SYNOPSIS
    
        Function used to get a file's metadata

    .EXAMPLE

        Get-FileMetadata -FilePath 'C:\recordings\my_greeting.wav'

        # Retuns metadata for file

    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # File path
        [Parameter(Mandatory=$true)][string]$FilePath
    )

    $objShell = New-Object -ComObject Shell.Application
    $objFolder = $objShell.namespace($(Split-Path $FilePath))
    $objFolder.items() | ? {$_.name -eq $(Split-Path $FilePath -Leaf)} | % {
        $FileMetaData = New-Object psobject
        for ($a = 0; $a  -le 266; $a++) {
            if ($objFolder.getDetailsOf($_, $a)) {
                $name  = $($objFolder.getDetailsOf($objFolder.items, $a))
                $value = $($objFolder.getDetailsOf($_, $a))
                $FileMetaData | Add-Member $name $value
            }
        }
        $FileMetaData
    }
}