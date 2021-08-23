 # Adjust this path to the same path as the "Export" script
$filePath = 'C:\Temp\Master-Skills.csv'

function Process-SkillLevelChanges
{
    Write-Host ""
    Write-Host ""

    $users = Get-Five9User


    $skillLevelChanges = @()

    $count = $users.Count
    $i = $count
    $j = 0

    foreach ($user in $users)
    {

        try
        {
            Write-Progress -Activity $user.userName -Status "$i Users Remaining.."  -PercentComplete (($j / $count) * 100)
            $i--
            $j++
        }
        catch
        {

        }

        $skillsFromImport = $importedCsv | ? {$_.type -match 'user' -and $_.userName -eq $user.userName}

        # iterate user's current skills
        foreach ($skill in $user.skills)
        {

            $skillFromImport = $null
            $skillFromImport = $skillsFromImport | ? {$_.skillName -eq $skill.skillName}

            if ($skillFromImport)
            {
                if ($skillFromImport.level -ne $skill.level)
                {
                    # skill level did not match, adjust it
                    $skillLevelChanges += New-Object psobject -Property @{
                        changeType = "Level"
                        userName = $user.userName
                        skillName = $skill.skillName
                        current_level = $skill.level.ToString()
                        excel_level = $skillFromImport.level.ToString()
                    }
                }
            }
        }
    }



    Write-Progress -Activity "Complete" -PercentComplete 100 -Completed: $true

    Write-Host ""

    if ($skillLevelChanges.count -lt 1)
    {
        Write-Host -ForegroundColor Cyan "No Skill Level changes found!"
        return
    }

    Write-Host -ForegroundColor Cyan "Skill Level Changes Found: "
    Write-Output $skillLevelChanges | select changeType,userName,skillName,current_level,excel_level | ft

    Write-Host ""

    $proceed = Read-Host "Would you like to perform these changes? y/n"

    if ($proceed -match '^y')
    {
        foreach ($change in $skillLevelChanges)
        {
            try
            {
                if ($change.changeType -eq 'Level')
                {
                    Write-Host -ForegroundColor Cyan "Set-Five9SkillMember -Name ""$($change.skillName)"" -Username ""$($change.userName)"" -SkillLevel $($change.excel_level)"
                    Set-Five9SkillMember -Name $change.skillName -Username $change.userName -SkillLevel $change.excel_level
                }
            }
            catch
            {
                Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
            }

        }
    }
}

function Process-ProfileSkillChanges 
{

    Write-Host ""
    Write-Host ""

    $profiles = Get-Five9UserProfile

    $count = $profiles.Count
    $i = $count
    $j = 0

    $profileSkillChanges = @()

    foreach ($profile in $profiles)
    {

        try
        {
            Write-Progress -Activity $profile.name -Status "$i Profiles Remaining.."  -PercentComplete (($j / $count) * 100)
            $i--
            $j++
        }
        catch
        {

        }

        $profilesFromImport = $importedCsv | ? {$_.type -match 'profile' -and $_.name -eq $profile.name}

        $differences = Compare-Object -ReferenceObject $profilesFromImport.skillName -DifferenceObject $profile.skills


        foreach ($diff in $differences)
        {

            <#
                == in both
                <= in Five9 but not in CSV (Remove skill from profile)
                => in CSV but not in Five9 (Add skill to profile)
            #>

            if ($diff.SideIndicator -eq '<=')
            {
                $profileSkillChanges += New-Object psobject -Property @{
                    changeType = 'Add'
                    profileName = $profile.name
                    skillName = $diff.InputObject
                }
            }
            elseif ($diff.SideIndicator -eq '=>')
            {
                $profileSkillChanges += New-Object psobject -Property @{
                    changeType = 'Remove'
                    profileName = $profile.name
                    skillName = $diff.InputObject
                }
            }
        }

    }

    
    Write-Progress -Activity "Complete" -PercentComplete 100 -Completed: $true


    if ($profileSkillChanges.Count -lt 1)
    {
        Write-Host -ForegroundColor Cyan "No Profile Skill Changes Found!"
        return
    }


    Write-Host ""

    Write-Host -ForegroundColor Cyan "Skill Level Changes Found: "
    Write-Output $profileSkillChanges | select changeType, profileName, skillName | ft

    Write-Host ""

    $proceed = Read-Host "Would you like to perform these changes? y/n"


    if ($proceed -match '^y')
    {
        Write-Host "Issuing the following commands:"
        Write-Host ""
        foreach ($change in $profileSkillChanges)
        {
            try
            {
                if ($change.changeType -eq 'Add')
                {
                    Write-Host -ForegroundColor Green "Add-Five9UserProfileSkill -Name ""$($change.profileName)"" -SkillName ""$($change.skillName)"""
                    Add-Five9UserProfileSkill -Name $change.profileName -SkillName $change.skillName
                }
                elseif ($change.changeType -eq 'Remove')
                {
                    Write-Host -ForegroundColor Magenta "Remove-Five9UserProfileSkill -Name ""$($change.profileName)"" -SkillName ""$($change.skillName)"""
                    Remove-Five9UserProfileSkill -Name $change.profileName -SkillName $change.skillName
                }
            }
            catch
            {
                Write-Host -ForegroundColor Red "Error: $($_.Exception.Message)"
            }

        }
    }
}


try
{
    $importedCsv = Import-Csv $filePath
}
catch
{
    return "Error import CSV: ""$filePath "" "
}

Process-SkillLevelChanges
Process-ProfileSkillChanges

 
