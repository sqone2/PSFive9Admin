function Get-Five9User
{
    <#
    .SYNOPSIS
    
        Function used to return Five9 user(s)

    .EXAMPLE
    
        Get-Five9User
    
        # Returns all Users
    
    .EXAMPLE
    
        Get-Five9User -NamePattern "jdoe@domain.com"
    
        # Returns user who matches the string "jdoe@domain.com"

    .EXAMPLE
    
        Get-Five9User -OutputPath 'C:\files\five9-users.csv'
    
        # Exports all users to a specified CSV location

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Optional regex parameter. If used, function will return only users matching regex string
        [Parameter(Mandatory=$false, Position=0)][string]$NamePattern = '.*',

        # Optional parameter. If used, users will be exported to specified CSV location
        [Parameter(Mandatory=$false)][string]$OutputPath
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop


        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning user(s) matching pattern '$($NamePattern)'"
        $response = $global:DefaultFive9AdminClient.getUsersInfo($NamePattern)

        $userList = @()
        $exportList = @()
        foreach ($user in $response)
        {
            $user.generalinfo | Add-Member -MemberType NoteProperty -Name agentGroups -Value $user.agentGroups -Force
            $user.generalinfo | Add-Member -MemberType NoteProperty -Name cannedReports -Value $user.cannedReports -Force
            $user.generalinfo | Add-Member -MemberType NoteProperty -Name roles -Value $user.roles -Force
            $user.generalinfo | Add-Member -MemberType NoteProperty -Name skills -Value $user.skills -Force

            $user.generalinfo | Add-Member -MemberType NoteProperty -Name admin -Value $false -Force
            $user.generalinfo | Add-Member -MemberType NoteProperty -Name agent -Value $false -Force
            $user.generalinfo | Add-Member -MemberType NoteProperty -Name reporting -Value $false -Force
            $user.generalinfo | Add-Member -MemberType NoteProperty -Name supervisor -Value $false -Force

            if ($user.roles.admin -ne $null)
            {
                $user.generalinfo.admin = $true
            }

            if ($user.roles.agent -ne $null)
            {
                $user.generalinfo.agent = $true
            }

            if ($user.roles.reporting -ne $null)
            {
                $user.generalinfo.reporting = $true
            }

            if ($user.roles.supervisor -ne $null)
            {
                $user.generalinfo.supervisor = $true
            }

            $userList += $user.generalinfo

            if ($PSBoundParameters.Keys -contains 'OutputPath')
            {
                $exportList += $user.generalinfo
            }

        }
       
        
        if ($PSBoundParameters.Keys -contains 'OutputPath')
        {

            try
            {
                foreach ($user in $exportList)
                {
                    $user.agentGroups = $user.agentGroups -join '|'
                    $user.cannedReports = $user.cannedReports -join '|'
                    $user.skills = ($user.skills | select @{n='skills';e={$_.skillName + ':' + $_.level}}).skills -join '|'

                    $roleString = ""

                    if ($user.roles.admin -ne $null)
                    {
                        $adminRoleString = $null
                        foreach ($adminRole in $user.roles.admin)
                        {
                            $adminRoleString
                        }
                    }

                    if ($user.roles.agent -ne $null)
                    {

                    }

                    if ($user.roles.reporting -ne $null)
                    {

                    }

                    if ($user.roles.supervisor -ne $null)
                    {

                    }
                }

                $properties = @('id','active','extension','fullName','userName','EMail','userProfileName','admin','agent','supervisor','reporting','firstName','lastName','federationId','startDate','canChangePassword','mustChangePassword','agentGroups','roles','skills','cannedReports','mediaTypeConfig','osLogin','phoneNumber','locale','unifiedCommunicationId','password')
                
                $objMembers = ($exportList[0] | Get-Member -MemberType Properties).name

                $properties += $objMembers | ? {$properties -notcontains $_}

                $userList | sort fullName | select $properties

            }
            catch
            {

            }

        }


        return $userList | sort fullName
    }
    catch
    {
        $_ | Write-PSFive9AdminError		$_ | Write-Error
    }

}


