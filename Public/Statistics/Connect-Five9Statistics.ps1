function Connect-Five9Statistics
{
    <#
    .SYNOPSIS
    
        Function used to create a web service proxy with the Five9 admin web service

    .EXAMPLE
    
        Connect-Five9Statistics
    
        # If user has already connected PowerShell to the Five9 Admin Web Service, those credentails will be used
        # Otherwise, the user will be prompted to enter their Five9 username and password

    .EXAMPLE
    
        Connect-Five9Statistics -DataCenter "EU"
    
        # Domain being connected to is loacated in the Five9 EU data center

    .EXAMPLE

        $username = 'jdoe@domain.com'
        $password = 'P@ssword!' | ConvertTo-SecureString -AsPlainText -Force
        $cred = New-Object -TypeName PSCredential -ArgumentList $username,$password
        Connect-Five9Statistics -Credential $cred
    
        # Create PSCredential object and connects to Five9 statistics web service

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # PSCredential object, such as one returned by the Get-Credential cmdlet.
        # If parameter is omitted, Get-Credential will be called.
        [Parameter(Mandatory=$false, Position=0)][PSCredential]$Credential,

        # Optional API version. See Five9 documentation for details on what is provided with each version. 
        # If omitted, most recent version will be used (recommended).
        [Parameter(Mandatory=$false)][string]$Version = '12',

        <# 
        Data center that contains the Five9 domain you are connecting to

        Options are:
            • US (Default) - United States data center
            • EU - European Union data center
        #>
        [Parameter(Mandatory=$false)][ValidateSet('US', 'EU')][string]$DataCenter = 'US',

        # Maximum inactivity allowed for the supervisor session from 60 – 1800seconds (30min). 
        # If omitted, the default value is 600 seconds (10 min)
        [Parameter(Mandatory=$false)][ValidateRange(60,1800)][int]$IdleTimeOutSeconds = 600,
        
        # Whether to log out a second agent or supervisor who is attempting to log into a station that is in use.
        [Parameter(Mandatory=$false)][bool]$ForceLogoutSession = $false,
        
        # Time zone offset.
        # If omitted, the default value is -7 (PST).
        [Parameter(Mandatory=$false)][ValidateRange(-12,14)][int]$TimeZoneOffset = '-7',
        
        <#
        Time range used to calculate aggregate statistics in Outbound Campaign Manager.
        Corresponds to Campaign Manager Rolling Period in the Supervisor VCC.

        Options are:
            • Minutes5 (Default)
            • Minutes10
            • Minutes15
            • Minutes30
            • Hour1
            • Hour2
            • Hour2
            • Hour3
            • Today
        #>
        [Parameter(Mandatory=$false)][ValidateSet('Minutes5','Minutes10','Minutes15','Minutes30','Hour1','Hour2','Hour3','Today')][string]$RollingPeriod = 'Minutes5',
        
        <#
        Time interval for aggregate statistics.

        Options are:
            • CurrentDay  (Default)
            • CurrentWeek
            • CurrentMonth
            • CurrentShift
            • Lifetime
            • RollingHour
        #>
        [Parameter(Mandatory=$false)][ValidateSet('CurrentDay','CurrentWeek','CurrentMonth','CurrentShift','Lifetime','RollingHour')][string]$StatisticsRange = 'CurrentDay',
        
        # Starting time for the day’s shift. Used to calculate certain statistics.
        # If omitted, the default value is '8am'
        [Parameter(Mandatory=$false)][datetime]$ShiftStart = '8am',

        # Only used by iPad applications
        [Parameter(Mandatory=$false)][string]$AppType = 'Custom',

        # Returns an object that contains the web service proxy
        [Parameter(Mandatory=$false)][switch]$PassThru = $false
    )

    try
    {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        if ($PSBoundParameters.Keys -contains 'Credential')
        {
            $statsCred = $Credential
        }
        elseif ($global:DefaultFive9AdminClient.Five9DomainName.Length -gt 0)
        {
            $statsCred = $global:DefaultFive9AdminClient.Credentials

            if ($PSBoundParameters.Keys -notcontains 'DataCenter')
            {
                $DataCenter = $global:DefaultFive9AdminClient.DataCenter
            }

            if ($PSBoundParameters.Keys -notcontains 'DataCenter')
            {
                $Version = $global:DefaultFive9AdminClient.Version
            }

        }
        else
        {
            $statsCred = Get-Credential -Message "Please enter your Five9 admin credentials"
        }

        if ($DataCenter -eq 'EU')
        {
            $wsdl = "https://api.five9.eu/wssupervisor/v$Version/SupervisorWebService?wsdl&user=$($statsCred.UserName)"
        }
        else
        {
            $wsdl = "https://api.five9.com/wssupervisor/v$Version/SupervisorWebService?wsdl&user=$($statsCred.UserName)"
        }

        Write-Verbose "Connecting to: $($wsdl)"

        $global:Five9StatisticsClient = New-WebServiceProxy -Uri $wsdl -Namespace "PSFive9Admin" -Class "PSFive9Admin" -ErrorAction: Stop


        $global:Five9StatisticsClient.Credentials          = $statsCred
        $global:Five9StatisticsClient.Credentials.UserName = $global:Five9StatisticsClient.Credentials.UserName
        $global:Five9StatisticsClient.Credentials.Domain   = $null


        # set session params
        
        $viewSettings = New-Object PSFive9Admin.viewSettings

        $viewSettings.appType = "Custom"

        $viewSettings.forceLogoutSession = $ForceLogoutSession
        $viewSettings.forceLogoutSessionSpecified = $true

        $viewSettings.idleTimeOut = $IdleTimeOutSeconds
        $viewSettings.idleTimeOutSpecified = $true

        $viewSettings.rollingPeriod = $RollingPeriod
        $viewSettings.rollingPeriodSpecified = $true

        $viewSettings.shiftStart = $ShiftStart.TimeOfDay.TotalMilliseconds

        $viewSettings.statisticsRange = $StatisticsRange
        $viewSettings.statisticsRangeSpecified = $true

        $viewSettings.timeZone = $TimeZoneOffset * 60 * 60 * 1000

        Write-Verbose "$($MyInvocation.MyCommand.Name): Setting Five9 Statistics Session Parameters." 

        $Five9StatisticsClient.setSessionParameters($viewSettings)

    }
    catch
    {
        throw "Error creating web service proxy to Five9 Statistics Web Service. $($_.Exception.Message)"
        return
    }


    if ($PassThru -eq $true)
    {
        return $global:Five9StatisticsClient
    }

    return

}

