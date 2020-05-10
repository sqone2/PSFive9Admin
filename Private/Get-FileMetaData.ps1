function Get-FileMetadata
{
    param
    (
        $FilePath
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