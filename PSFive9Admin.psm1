try
{
    Write-Host $("$PSScriptRoot\Public\")
    Write-Host $("$PSScriptRoot\Private\")
    $public  = Get-ChildItem -Path "$PSScriptRoot\Public\" -Filter "*.ps1" -Recurse
    $private = Get-ChildItem -Path "$PSScriptRoot\Private\" -Filter "*.ps1" -Recurse
}
catch
{
    Write-Error -Message "Error getting files from PSScriptRoot ""$PSScriptRoot"". Aborting Module Import. Message: $($_.Exception.Message)"
    return
}

$toImport = @()
$toImport += $public
$toImport += $private

#Dot source the files
foreach ($file in $toImport)
{
    try
    {
        . $file.FullName
    }
    catch
    {
        Write-Error -Message "Failed to import function ""$($file.Name)"" Message: $($_.Exception.Message)"
        continue
    }
}


Export-ModuleMember -Function $public.Basename

