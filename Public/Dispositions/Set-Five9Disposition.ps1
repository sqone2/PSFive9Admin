function Set-Five9Disposition
{
    <#
    .SYNOPSIS

        Function used to modify a Five9 disposition

    .EXAMPLE

        Set-Five9Disposition -Name "Default-Disposition" -NewName "Old-Disposition" -Type: AddActiveNumber

        # Changes existing disposition from "Default-Disposition" to "Old-Disposition", and changes Type to "AddActiveNumber"
    #>

    [CmdletBinding(PositionalBinding = $false)]
    param
    (
        # Name of existing disposition
        [Parameter(Mandatory = $true, Position = 0)][string]$Name,

        # Optional parameter. If provided, existing disposition's name will be changed
        [Parameter(Mandatory = $false)][string]$NewName,

        # Description of disposition
        [Parameter(Mandatory = $false)][string]$Description,

        # Whether the agent needs to complete a worksheet before selecting a disposition
        [Parameter(Mandatory = $false)][bool]$AgentMustCompleteWorksheet,

        # Whether the agent is prompted to confirm the selection of the disposition
        [Parameter(Mandatory = $false)][bool]$AgentMustConfirm,

        # Whether the agent is prompted to confirm the selection of the disposition
        [Parameter(Mandatory = $false)][bool]$ResetAttemptsCounter,

        # Whether call details are sent as an email notification when the disposition is used by an agent
        [Parameter(Mandatory = $false)][bool]$SendEmailNotification,

        # Whether call details are sent as an instant message in the Five9 system when the disposition is used by an agent
        [Parameter(Mandatory = $false)][bool]$SendIMNotification,

        # Whether the call is included in the first call resolution statistics (customer’s needs addressed in the first call). Used primarily for inbound campaigns
        [Parameter(Mandatory = $false)][bool]$TrackAsFirstCallResolution,

        <#
        Type of disposition

        Options are:
            • FinalDisp - Any contact number of the contact is not dialed again by the current campaign
            • FinalApplyToCampaigns - Contact is not dialed again by any campaign that contains the disposition
            • AddActiveNumber - Adds the number dialed to the DNC list
            • AddAndFinalize - Adds the call results to the campaign history. This record is no longer dialing in this campaign.
                             Does not add the contact’s other phone numbers to the DNC list.
            • AddAllNumbers - Adds all the contact’s phone numbers to the DNC list
            • DoNotDial - Number is not dialed in the campaign, but other numbers from the CRM record can be dialed
            • RedialNumber - Number is dialed again when the list to dial is completed, and the dialer starts again from the beginning.
        #>
        [Parameter(Mandatory = $false)][ValidateSet("FinalDisp", "FinalApplyToCampaigns", "AddActiveNumber", "AddAndFinalize", "AddAllNumbers", "DoNotDial", "RedialNumber")][string]$Type,

        # Number of redial attempts.
        # Only used when -Type is set to "RedialNumber"
        [Parameter(Mandatory = $false)][bool]$UseRedialTimer,

        # Whether this disposition uses a redial timer
        # Only used when -Type is set to "RedialNumber"
        [Parameter(Mandatory = $false)][ValidateRange(1, 99)][int]$RedialAttempts,

        # Number of Days
        # Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"
        [Parameter(Mandatory = $false)][ValidateRange(0, 59)][int]$RedialTimerDays,

        # Number of Hours
        # Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"
        [Parameter(Mandatory = $false)][ValidateRange(0, 23)][int]$RedialTimerHours,

        # Number of Minutes
        # Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"
        [Parameter(Mandatory = $false)][ValidateRange(0, 59)][int]$RedialTimerMinutes,

        # Number of Seconds
        # Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"
        [Parameter(Mandatory = $false)][ValidateRange(0, 59)][int]$RedialTimerSeconds,

        # Whether the agent can change the redial timer for this disposition
        # Only used when -Type is set to "RedialNumber"
        [Parameter(Mandatory = $false)][string]$AllowChangeTimer

    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        # $dispositionToModify = $null
        # try
        # {
        #     $dispositionToModify = $global:DefaultFive9AdminClient.getDispositions($Name)
        # }
        # catch
        # {

        # }

        # if ($dispositionToModify.Count -gt 1)
        # {
        #     throw "Multiple Dispositions were found using query: ""$Name"". Please try using the exact name of the disposition you're trying to modify."
        #     return
        # }

        # if ($null -eq $dispositionToModify)
        # {
        #     throw "Cannot find a Disposition with name: ""$Name"". Remember that Name is case sensitive."
        #     return
        # }

        #  $dispositionToModify = $dispositionToModify | select -First 1



        $dispositionToModify = New-Object PSFive9Admin.disposition
        $dispositionToModify.name = $Name

        if ($PSBoundParameters.Keys -contains "Description")
        {
            $dispositionToModify.description = $Description
        }

        if ($PSBoundParameters.Keys -contains "AgentMustCompleteWorksheet")
        {
            $dispositionToModify.agentMustCompleteWorksheet = $AgentMustCompleteWorksheet
            $dispositionToModify.agentMustCompleteWorksheetSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains "AgentMustConfirm")
        {
            $dispositionToModify.agentMustConfirm = $AgentMustConfirm
            $dispositionToModify.agentMustConfirmSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains "ResetAttemptsCounter")
        {
            $dispositionToModify.resetAttemptsCounter = $ResetAttemptsCounter
            $dispositionToModify.resetAttemptsCounterSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains "SendEmailNotification")
        {
            $dispositionToModify.sendEmailNotification = $SendEmailNotification
            $dispositionToModify.sendEmailNotificationSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains "SendIMNotification")
        {
            $dispositionToModify.sendIMNotification = $SendIMNotification
            $dispositionToModify.sendIMNotificationSpecified = $true
        }

        if ($PSBoundParameters.Keys -contains "TrackAsFirstCallResolution")
        {
            $dispositionToModify.trackAsFirstCallResolution = $TrackAsFirstCallResolution
            $dispositionToModify.trackAsFirstCallResolutionSpecified = $true
        }


        if ($PSBoundParameters.Keys -contains "Type")
        {
            $dispositionToModify.type = $Type
            $dispositionToModify.typeSpecified = $true

            # only set timer values if type is set to RedialNumber
            if ($Type -eq "RedialNumber" -and $PSBoundParameters.Keys -contains "UseRedialTimer")
            {
                $dispositionToModify.typeParameters = New-Object PSFive9Admin.dispositionTypeParams

                $dispositionToModify.typeParameters.useTimer = $UseRedialTimer
                $dispositionToModify.typeParameters.useTimerSpecified = $true

                if ($UseRedialTimer -eq $true)
                {
                    if ($RedialAttempts -lt 1)
                    {
                        throw "When -UseRedialTimer is set to True, you must also set -RedialAttempts to a value between 1-99."
                        return
                    }

                    if ($RedialTimerDays -lt 1 -and $RedialTimerHours -lt 1 -and $RedialTimerMinutes -lt 1)
                    {
                        throw "When -UseRedialTimer is set to True, the total -RedialTimer<unit> values must be set to at least 1 minute. For example, to redial a record after 8.5 hours, use -RedialTimerHours 8 -RedialTimerMinutes 30"
                        return
                    }

                    $dispositionToModify.typeParameters.timer = New-Object PSFive9Admin.timer
                    $dispositionToModify.typeParameters.timer.days = $RedialTimerDays
                    $dispositionToModify.typeParameters.timer.hours = $RedialTimerHours
                    $dispositionToModify.typeParameters.timer.minutes = $RedialTimerMinutes
                    $dispositionToModify.typeParameters.timer.seconds = $RedialTimerSeconds

                    $dispositionToModify.typeParameters.attempts = $RedialAttempts
                    $dispositionToModify.typeParameters.attemptsSpecified = $true

                }

                if ($PSBoundParameters.Keys -contains "AllowChangeTimer")
                {
                    $dispositionToModify.typeParameters.allowChangeTimer = $AllowChangeTimer
                    $dispositionToModify.typeParameters.allowChangeTimerSpecified = $true
                }

            }

        }


        Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying disposition '$Name'."
        $response = $global:DefaultFive9AdminClient.modifyDisposition($dispositionToModify)

        if ($PSBoundParameters.Keys -contains "NewName")
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying disposition name from: '$Name' to '$NewName'."
            $response = $global:DefaultFive9AdminClient.renameDisposition($Name, $NewName)
        }

        return $response

    }
    catch
    {
        $_ | Write-PSFive9AdminError
        $_ | Write-Error
    }
}
