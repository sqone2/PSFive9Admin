function Set-Five9SkillVoicemailGreeting
{
    <#
    .SYNOPSIS
    
        Function used to upload a new voicemail greeting for a skill.

        If a voicemail greeting already exists for the skill, it is replaced. 
        For more information about the WAV formats supported by the VCC, see the Basic Administrator's Guide.

    .EXAMPLE

        Set-Five9SkillVoicemailGreeting -SkillName 'Inbound Sales' -FilePath 'C:\recordings\my_greeting.wav'

        # Uploads new voicemail greeting for skill Inbound Sales

    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Skill name to upload new greeting to
        [Parameter(Mandatory=$true)][string]$SkillName,

        # File path to be uploaded to existing prompt
        # Note: You can only use this parameter if prompt is already a WAV prompt
        [Parameter(Mandatory=$true)][string]$FilePath

    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

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


        $Wav = [IO.File]::ReadAllBytes($wavFile.FullName)
        $Base64Wav = [Convert]::ToBase64String($Wav)
        $ConvertedWav = [System.Convert]::FromBase64String($Base64Wav)

        Write-Verbose "$($MyInvocation.MyCommand.Name): Uploading skill voicemail greeting: '$($wavFile.Name)' > '$SkillName'." 
        return $global:DefaultFive9AdminClient.setSkillVoicemailGreeting($SkillName, $ConvertedWav)

    }
    catch
    {
        $_ | Write-PSFive9AdminError
		$_ | Write-Error
    }
}