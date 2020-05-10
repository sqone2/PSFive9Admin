function Set-Five9Prompt
{
    <#
    .SYNOPSIS
    
        Function used to modify an existing WAV or TTS prompt in Five9

    .EXAMPLE

        Set-Five9Prompt -Name 'WAV_Greeting' -FilePath 'C:\recordings\my_greeting.wav'

        # Modifies an existing WAV prompt using a local file

    .EXAMPLE

        Set-Five9Prompt -Name 'TTS_Greeting' -Text "Thanks for calling! Please hold while we transfer your call."

        # Modifies an existing TTS prompt
 
    .EXAMPLE
    
        Set-Five9Prompt -Name date_prompt -Text "2020-02-04" -Voice: Tom -SayAs: Date -SayAsFormat: Date_DMY
    
        # Modifies an existing TTS prompt using additional parameters


    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Name of prompt to be modified
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # New description
        [Parameter(Mandatory=$false)][string]$Description,

        # File path to be uploaded to existing prompt
        # Note: You can only use this parameter if prompt is already a WAV prompt
        [Parameter(Mandatory=$false)][string]$FilePath,

        # Text to convert to TTS for existing prompt
        # Note: You can only use this parameter if prompt is already a TTS prompt
        [Parameter(Mandatory=$false)][string]$Text,

        # Voice used to pronounce the TTS prompt
        [Parameter(Mandatory=$false)][ValidateSet('Samantha','Donna','Jennifer','Jill','Tom')][string]$Voice,

        # Describes how letters, numbers, and symbols are pronounced
        [Parameter(Mandatory=$false)][ValidateSet('Default','Words','Acronym','Address','Cardinal','Currency','Date','Decimal','Digits','Duration','Fraction','Letters','Measure','Name','Net','Telephone','Ordinal','Spell','Time')][string]$SayAs,

        # Date and time format of the prompt
        [Parameter(Mandatory=$false)][ValidateSet('NoFormat','Default','Date_MDY','Date_DMY','Date_YMD','Date_YM','Date_MY','Date_DM','Date_MD','Date_Y','Date_M','Date_D','Duration_HMS','Duration_HM','Duration_MS','Duration_H','Duration_M','Duration_S','Net_URI','Net_EMAIL','Time_HMS','Time_HM','Time_H')][string]$SayAsFormat

    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        
        $promptToModify = $null
        try
        {
            $promptToModify = $global:DefaultFive9AdminClient.getPrompt($Name)
        }
        catch
        {

        }

        if ($promptToModify -eq $null)
        {
            throw "Cannot find a Five9 prompt with name: ""$Name"". Remember that Name is case sensitive."
            return
        }


        $promptToModify = $promptToModify | Select-Object -First 1


        if ($PSBoundParameters.Keys -contains "Description")
        {
            $promptToModify.description = $Description
        }


        if ($promptToModify.type -eq "PreRecorded")
        {
            
            if ($PSBoundParameters.Keys -notcontains "FilePath")
            {
                throw "Parameter '-FilePath' must be specified when modifying a WAV prompt."
                return
            }

            $wavFile = $null
            try
            {
                $wavFile = Get-Item $FilePath
            }
            catch
            {

            }

            if ($wavFile -eq $null)
            {
                throw "Could not find file '$FilePath'"
                return
            }
            

            if ($wavFile.Extension -ne '.wav')
            {
                throw "File being uploaded must be WAVE audio, ITU G.711 mu-law, mono 8000 Hz. You can convert file by going to 'https://G711.org/' and selecting type 'u-law (8Khz, Mono, u-law)'."
                return
            }
 
            
            try
            {
                $metadata = $null
                $metadata = Get-FileMetaData -FilePath $FilePath
            }
            catch
            {

            }

            if ($metadata -and $metadata.'Bit rate' -ne '64kbps')
            {
                throw "File being uploaded must be WAVE audio, ITU G.711 mu-law, mono 8000 Hz. You can convert file by going to 'https://G711.org/' and selecting type 'u-law (8Khz, Mono, u-law)'."
                return
            }


            $Wav = [IO.File]::ReadAllBytes($FilePath)
            $Base64Wav = [Convert]::ToBase64String($Wav)
            $ConvertedWav = [System.Convert]::FromBase64String($Base64Wav)

            Write-Verbose "$($MyInvocation.MyCommand.Name): Uploading new WAV file to prompt. '$($wavFile.Name)' > '$Name'." 
            return $global:DefaultFive9AdminClient.modifyPromptWavInline($promptToModify, $ConvertedWav)

        }
        elseif ($promptToModify.type -eq "TTSGenerated")
        {
            if ($Text.Length -lt 1)
            {
                throw "Parameter '-Text' must be specified when modifying a TTS prompt."
                return
            }

            $ttsInfo = New-Object PSFive9Admin.ttsInfo
            $ttsInfo.text = $Text

            if ($PSBoundParameters.Keys -contains "SayAs")
            {
                $ttsInfo.sayAs = $SayAs
                $ttsInfo.sayAsSpecified = $true
            }

            if ($PSBoundParameters.Keys -contains "SayAsFormat")
            {
                $ttsInfo.sayAsFormat = $SayAsFormat
                $ttsInfo.sayAsFormatSpecified = $true
            }

            if ($PSBoundParameters.Keys -contains "Voice")
            {
                $ttsInfo.voice = $Voice
            }
 

            Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying TTS prompt '$Name'." 
            return $global:DefaultFive9AdminClient.modifyPromptTTS($promptToModify, $ttsInfo)

        }


    }
    catch
    {
        throw $_
    }
}
