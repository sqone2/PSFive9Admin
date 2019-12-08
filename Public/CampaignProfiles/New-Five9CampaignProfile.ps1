<#
.SYNOPSIS
    
    Function used to create a new campaign profile in Five9
 
.PARAMETER Name

    Name of new campaign profile
    Only required parameter

.PARAMETER Description

     Description of new campaign profile

.PARAMETER InitialCallPriority

    Priority initially assigned to inbound and outbound calls on a scale of 1 to 100. 
    Inbound calls have a default priority of 60. 
    Calls with a higher priority are answered first, regardless of their time in a queue. 
    To force calls from a campaign to be answered before those from other campaigns, increase the priority by 1.

.PARAMETER MaxCharges

    Applies to inbound and outbound calls. 
    Maximum dollar amount for long distance charges. 
    The campaign stops automatically when this amount is reached. 
    Zero means no limit.

.PARAMETER DialingTimeout

    Time to wait before disconnecting an unanswered call and logging it as No Answer.
    The default is 17 seconds


.PARAMETER NumberOfAttempts

    For outbound campaigns, number of dialing attempts for phone numbers in a list record, including redials due to disposition settings

.PARAMETER ANI

    ANI to send with outbound call

. PARAMETER IncludeNumber1

    Whether to call number1 in the campaign associated with the profile

. PARAMETER IncludeNumber2

    Whether to call number2 in the campaign associated with the profile

. PARAMETER IncludeNumber3

    Whether to call number3 in the campaign associated with the profile

. PARAMETER Number1StartTime

    When, in local time, to start dialing number1 numbers for an outbound campaign. i.e. '8am' or '8:30am'

. PARAMETER Number1StopTime

    When, in local time, to stop dialing number1 numbers. i.e. '7pm' or '7:30pm'

. PARAMETER Number2StartTime

    When, in local time, to start dialing number2 numbers for an outbound campaign. i.e. '8am' or '8:30am'

. PARAMETER Number2StopTime

    When, in local time, to stop dialing number2 numbers. i.e. '7pm' or '7:30pm'


. PARAMETER Number3StartTime

    When, in local time, to start dialing number3 numbers for an outbound campaign. i.e. '8am' or '8:30am'

. PARAMETER Number3StopTime

    When, in local time, to stop dialing number3 numbers. i.e. '7pm' or '7:30pm'


. PARAMETER DialingOrder

    Contains the dialing order of phone numbers when contact records have multiple phone numbers. i.e. -DialingOrder 'Number1', 'Number2', 'Number3'

. PARAMETER DialASAPTimeout

    Duration before records that are not dialed are removed from the ASAP queue and are treated as normal records

. PARAMETER DialASAPTimeoutPeriod

    Unit that specifies the dial ASAP timeout
    Options are:
        • Second 
        • Minute
        • Hour
        • Day

. PARAMETER DialASAPSortOrder
    
    Order for dialing numbers in the ASAP queue
    Options are:
    • FIFO (Default) - First in, first out: oldest added are called first
    • LIFO - Last in, first out: newest added called first
    • ContactFields - Sort order of the campaign profile

        
.EXAMPLE
    
    $adminClient = New-Five9AdminClient -Username "user@domain.com" -Password "P@ssword!"
    New-Five9CampaignProfile -Five9AdminClient $adminClient -Name "Cold-Calls-Profile"
    
    # Creates new campaign profile using all default values

.EXAMPLE
    
    New-Five9CampaignProfile -Five9AdminClient $adminClient -Name "Cold-Calls-Profile" -InitialCallPriority 90 -NumberOfAttempts 10 -ANI '5991230001' `
                             -IncludeNumber1 $true -IncludeNumber2: $false -IncludeNumber3 $false `
                             -Number1StartTime 9am -Number1StopTime 10am -Number2StartTime 9am -Number2StopTime 10pm -Number3StartTime 10am -Number3StopTime 11pm `
                             -DialingOrder 'Number3', 'Number1', 'number2' -DialASAPTimeout 9 -DialASAPTimeoutPeriod: Minute -DialASAPSortOrder: ContactFields


    # Creates new campaign profile including additional parameters


 
#>
function New-Five9CampaignProfile
{
    param
    ( 
        [Parameter(Mandatory=$true)][PSFive9Admin.WsAdminService]$Five9AdminClient,

        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$false)][string]$Description,
        [Parameter(Mandatory=$false)][ValidateRange(1,100)][int]$InitialCallPriority,
        [Parameter(Mandatory=$false)][int]$MaxCharges,
        [Parameter(Mandatory=$false)][ValidateRange(10,2147483)][int]$DialingTimeout,
        [Parameter(Mandatory=$false)][ValidateRange(1,127)][int]$NumberOfAttempts,
        [Parameter(Mandatory=$false)][string]$ANI,

        [Parameter(Mandatory=$false)][bool]$IncludeNumber1 = $true,
        [Parameter(Mandatory=$false)][bool]$IncludeNumber2 = $true,
        [Parameter(Mandatory=$false)][bool]$IncludeNumber3 = $true,

        [Parameter(Mandatory=$false)][datetime]$Number1StartTime = '8am',
        [Parameter(Mandatory=$false)][datetime]$Number1StopTime = '9pm',

        [Parameter(Mandatory=$false)][datetime]$Number2StartTime = '8am',
        [Parameter(Mandatory=$false)][datetime]$Number2StopTime = '9pm',

        [Parameter(Mandatory=$false)][datetime]$Number3StartTime = '8am',
        [Parameter(Mandatory=$false)][datetime]$Number3StopTime = '9pm',

        [Parameter(Mandatory=$false)][ValidatePattern('Number[1-3]')][string[]]$DialingOrder = @('Number1','Number2','Number3'),

        [Parameter(Mandatory=$false)][int]$DialASAPTimeout = 1,
        [Parameter(Mandatory=$false)][ValidateSet('Second', 'Minute', 'Hour', 'Day')][string]$DialASAPTimeoutPeriod = 'Hour',
        [Parameter(Mandatory=$false)][ValidateSet('LIFO', 'FIFO', 'ContactFields')][string]$DialASAPSortOrder = 'LIFO'

    )

    $campaignProfile = New-Object PSFive9Admin.campaignProfileInfo
    $campaignProfile.dialingSchedule = New-Object PSFive9Admin.campaignDialingSchedule
    

    $campaignProfile.name = $Name

    if ($PSBoundParameters.Keys -contains 'Description')
    {
        $campaignProfile.description = $Description
    }

    if ($PSBoundParameters.Keys -contains 'InitialCallPriority')
    {
        $campaignProfile.initialCallPriority = $InitialCallPriority
        $campaignProfile.initialCallPrioritySpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'MaxCharges')
    {
        $campaignProfile.maxCharges = $MaxCharges
        $campaignProfile.maxChargesSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'DialingTimeout')
    {
        $campaignProfile.dialingTimeout = $DialingTimeout
        $campaignProfile.dialingTimeoutSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'NumberOfAttempts')
    {
        $campaignProfile.numberOfAttempts = $NumberOfAttempts
        $campaignProfile.numberOfAttemptsSpecified = $true
    }

    if ($PSBoundParameters.Keys -contains 'ANI')
    {
        $campaignProfile.ANI = $ANI
    }

    if ($IncludeNumber1 -eq $true)
    {
        $campaignProfile.dialingSchedule.includeNumbers += 'Primary'
    }

    if ($IncludeNumber2 -eq $true)
    {
        $campaignProfile.dialingSchedule.includeNumbers += 'Alt1'
    }

    if ($IncludeNumber3 -eq $true)
    {
        $campaignProfile.dialingSchedule.includeNumbers += 'Alt2'
    }


    $number1Schedule = New-Object PSFive9Admin.campaignNumberSchedule
    $number1Schedule.number = 'Primary'
    $number1Schedule.numberSpecified = $true
    $number1Schedule.startTime = New-Object PSFive9Admin.timer
    $number1Schedule.startTime.hours = $Number1StartTime.Hour
    $number1Schedule.startTime.minutes = $Number1StartTime.Minute
    $number1Schedule.stopTime = New-Object PSFive9Admin.timer
    $number1Schedule.stopTime.hours = $Number1StopTime.Hour
    $number1Schedule.stopTime.minutes = $Number1StopTime.Minute

    $number2Schedule = New-Object PSFive9Admin.campaignNumberSchedule
    $number2Schedule.number = 'Alt1'
    $number2Schedule.numberSpecified = $true
    $number2Schedule.startTime = New-Object PSFive9Admin.timer
    $number2Schedule.startTime.hours = $Number2StartTime.Hour
    $number2Schedule.startTime.minutes = $Number2StartTime.Minute
    $number2Schedule.stopTime = New-Object PSFive9Admin.timer
    $number2Schedule.stopTime.hours = $Number2StopTime.Hour
    $number2Schedule.stopTime.minutes = $Number2StopTime.Minute

    $number3Schedule = New-Object PSFive9Admin.campaignNumberSchedule
    $number3Schedule.number = 'Alt2'
    $number3Schedule.numberSpecified = $true
    $number3Schedule.startTime = New-Object PSFive9Admin.timer
    $number3Schedule.startTime.hours = $Number3StartTime.Hour
    $number3Schedule.startTime.minutes = $Number3StartTime.Minute
    $number3Schedule.stopTime = New-Object PSFive9Admin.timer
    $number3Schedule.stopTime.hours = $Number3StopTime.Hour
    $number3Schedule.stopTime.minutes = $Number3StopTime.Minute

    $campaignProfile.dialingSchedule.dialingSchedules += $number1Schedule
    $campaignProfile.dialingSchedule.dialingSchedules += $number2Schedule
    $campaignProfile.dialingSchedule.dialingSchedules += $number3Schedule



    if ($PSBoundParameters.Keys -contains 'DialingOrder')
    {
        if ($DialingOrder.Count -ne 3)
        {
            throw "Parameter ""-DialingOrder"" must be an array that contains 3 strings in the order you would like to dial. i.e. -DialingOrder 'Number1', 'Number2', 'Number3'"
            return
        }

        $dialOrderMapping = @{
            'Number1,Number2,Number3' = 'PrimaryAlt1Alt2'
            'Number1,Number3,Number2' = 'PrimaryAlt2Alt1'
            'Number2,Number1,Number3' = 'Alt1PrimaryAlt2'
            'Number2,Number3,Number1' = 'Alt1Alt2Primary'
            'Number3,Number1,Number2' = 'Alt2PrimaryAlt1'
            'Number3,Number2,Number1' = 'Alt2Alt1Primary'
        }

        $dialOrderString = $dialOrderMapping[$DialingOrder -join ',']

        if ($dialOrderString.Length -lt 5)
        {
            Write-Warning -Message 'There was an error processing the DialingOrder parameter. Dialing order will not be modified on this campign profile. Please see ""Get-Help Set-Five9CampaignProfileSchedule -Full"" ' -ErrorAction: Continue
        }
        else
        {
            $campaignProfile.dialingSchedule.dialingOrder = $dialOrderString
            $campaignProfile.dialingSchedule.dialingOrderSpecified = $dialOrderString
        }


        $campaignProfile.dialingSchedule.dialASAPTimeout = $DialASAPTimeout
        $campaignProfile.dialingSchedule.dialASAPTimeoutSpecified = $true

        $campaignProfile.dialingSchedule.dialASAPTimeoutPeriod = $DialASAPTimeoutPeriod
        $campaignProfile.dialingSchedule.dialASAPTimeoutPeriodSpecified = $true

        $campaignProfile.dialingSchedule.dialASAPSortOrder = $DialASAPSortOrder
        $campaignProfile.dialingSchedule.dialASAPSortOrderSpecified = $true

    }
    

    $response = $Five9AdminClient.createCampaignProfile($campaignProfile)


    return $response

}
