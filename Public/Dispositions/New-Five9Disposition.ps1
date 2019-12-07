<#
.SYNOPSIS
    
    Function used to create a new Five9 disposition

.PARAMETER Five9AdminClient
 
    Mandatory parameter. SOAP Proxy Client Object. Use function "New-Five9AdminClient" to get SOAP client

.PARAMETER Name

    Name of new disposition. Only required parameter.

.PARAMETER Description

    Description of new disposition

.PARAMETER AgentMustCompleteWorksheet

    Whether the agent needs to complete a worksheet before selecting a disposition

.PARAMETER AgentMustConfirm

    Whether the agent is prompted tconfirm the selection of the disposition

.PARAMETER ResetAttemptsCounter

    Whether the agent is prompted to confirm the selection of the disposition

.PARAMETER SendEmailNotification

    Whether call details are sent as an email notification when the disposition is used by an agent

.PARAMETER SendIMNotification

    Whether call details are sent as an instant message in the Five9 system when the disposition is used by an agent

.PARAMETER TrackAsFirstCallResolution

    Whether the call is included in the first call resolution statistics (customer’s needs addressed in the first call). Used primarily for inbound campaigns

.PARAMETER Type

    Type of disposition

.PARAMETER UseRedialTimer

    Whether this disposition uses a redial timer
    Only used when -Type is set to "RedialNumber"

.PARAMETER RedialAttempts

    Number of redial attempts. 
    Only used when -Type is set to "RedialNumber"

.PARAMETER AllowChangeTimer

    Whether the agent can change the redial timer for this disposition
    Only used when -Type is set to "RedialNumber"

.PARAMETER RedialTimerDays

    Number of Days
    Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"

.PARAMETER RedialTimerHours

    Number of Hours
    Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"

.PARAMETER RedialTimerMinutes

    Number of Minutes
    Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"

.PARAMETER RedialTimerSeconds
    
    Number of Seconds
    Only used when -Type is set to "RedialNumber" and -UseRedialTimer is set to "True"


   
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    New-Five9Disposition -Five9AdminClient $adminClient -Name "Default-Disposition"

    # Creates a new disposition using system default values
    
.EXAMPLE
    
    New-Five9Disposition -Five9AdminClient $adminClient -Name "Requested-Call-Back" -Description "Used when customer requests a callback." -AgentMustCompleteWorksheet $true -SendEmailNotification $true -Type: RedialNumber -UseRedialTimer $true -RedialAttempts 5 -RedialTimerHours 12

    
    # Creates a new disposition using specified values
    
 
#>
function New-Five9Disposition
{
    [CmdletBinding(PositionalBinding=$false)]
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][string]$Description,

        [Parameter(Mandatory=$false)][bool]$AgentMustCompleteWorksheet,
        [Parameter(Mandatory=$false)][bool]$AgentMustConfirm,
        [Parameter(Mandatory=$false)][bool]$ResetAttemptsCounter,
        [Parameter(Mandatory=$false)][bool]$SendEmailNotification,
        [Parameter(Mandatory=$false)][bool]$SendIMNotification,
        [Parameter(Mandatory=$false)][bool]$TrackAsFirstCallResolution,

        [Parameter(Mandatory=$false)][ValidateSet("FinalDisp", "FinalApplyToCampaigns", "AddActiveNumber", "AddAndFinalize", "AddAllNumbers", "DoNotDial", "RedialNumber")][string]$Type,

        [Parameter(Mandatory=$false)][bool]$UseRedialTimer,
        [Parameter(Mandatory=$false)][ValidateRange(1,99)][int]$RedialAttempts,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$RedialTimerDays,
        [Parameter(Mandatory=$false)][ValidateRange(0,23)][int]$RedialTimerHours,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$RedialTimerMinutes,
        [Parameter(Mandatory=$false)][ValidateRange(0,59)][int]$RedialTimerSeconds,

        [Parameter(Mandatory=$false)][string]$AllowChangeTimer

    )


    $disposition = New-Object PSFive9Admin.disposition
    $disposition.name = $Name
    $disposition.description = $Description

    if ($PSBoundParameters.Keys -contains "AgentMustCompleteWorksheet")
    {
        $disposition.agentMustCompleteWorksheet = $AgentMustCompleteWorksheet
        $disposition.agentMustCompleteWorksheetSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains "AgentMustConfirm")
    {
        $disposition.agentMustConfirm = $AgentMustConfirm
        $disposition.agentMustConfirmSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains "ResetAttemptsCounter")
    {
        $disposition.resetAttemptsCounter = $ResetAttemptsCounter
        $disposition.resetAttemptsCounterSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains "SendEmailNotification")
    {
        $disposition.sendEmailNotification = $SendEmailNotification
        $disposition.sendEmailNotificationSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains "SendIMNotification")
    {
        $disposition.sendIMNotification = $SendIMNotification
        $disposition.sendIMNotificationSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains "TrackAsFirstCallResolution")
    {
        $disposition.trackAsFirstCallResolution = $TrackAsFirstCallResolution
        $disposition.trackAsFirstCallResolutionSpecified = $true
    }
    
   
    if ($PSBoundParameters.Keys -contains "Type")
    {
        $disposition.type = $Type
        $disposition.typeSpecified = $true

         # only set timer values if type is set to RedialNumber
        if ($Type -eq "RedialNumber" -and $PSBoundParameters.Keys -contains "UseRedialTimer")
        {
            $disposition.typeParameters = New-Object PSFive9Admin.dispositionTypeParams

            $disposition.typeParameters.useTimer = $UseRedialTimer
            $disposition.typeParameters.useTimerSpecified = $true

            if ($UseRedialTimer -eq $true)
            {
                if ($RedialAttempts -lt 1)
                {
                    throw "When -UseRedialTimer is set to True, you must also set -RedialAttempts to a value between 1-99."
                    return
                }

                if ($RedialTimerDays -lt 1 -and $RedialTimerHours -lt 1 -and $RedialTimerMinutes -lt 1)
                {
                    throw "When -UseRedialTimer is set to True, the total -RedailTimer<unit> values must be set to at least 1 minute. For example, to redial a record after 8.5 hours, use -RedialTimerHours 8 -RedialTimerMinutes 30"
                    return
                }

                $disposition.typeParameters.timer = New-Object PSFive9Admin.timer
                $disposition.typeParameters.timer.days = $RedialTimerDays
                $disposition.typeParameters.timer.hours = $RedialTimerHours
                $disposition.typeParameters.timer.minutes = $RedialTimerMinutes
                $disposition.typeParameters.timer.seconds = $RedialTimerSeconds

                $disposition.typeParameters.attempts = $RedialAttempts
                $disposition.typeParameters.attemptsSpecified = $true

            }

            if ($PSBoundParameters.Keys -contains "AllowChangeTimer")
            {
                $disposition.typeParameters.allowChangeTimer = $AllowChangeTimer
                $disposition.typeParameters.allowChangeTimerSpecified = $true
            }

        }

    }


    return $Five9AdminClient.createDisposition($disposition)

}

