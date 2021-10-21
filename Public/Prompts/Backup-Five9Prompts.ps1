function Backup-Five9Prompts
{
    <#
    .SYNOPSIS
    
        Function will backup all domain prompts into a single IVR script which can be exported and imported into a different domain

        Steps:
            1) Execute Backup-Five9Prompts function
            2) Open newly created IVR script named "_prompt_backup" by default
            3) Inside of IVR Script click Actions > Backup > Choose the backup path > Click Backup
            4) You can then restore prompts on a different domain by creating a new IVR script in that domain and clicking Actions > Restore > Choose ZIP file from previous step

    .EXAMPLE
    
        Backup-Five9Prompts
    
        # Creates a new IVR script named "_prompt_backup" which has a play module containing all Prompts on the domain
    
    .EXAMPLE
    
        Backup-Five9Prompts -BackupIvrScriptName 'All_Prompts'
    
        # Creates a new IVR script named 'All_Prompts' which has a play module containing all Prompts on the domain

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Optional name of new IVR script which will contain a backup of all Prompts
        [Parameter(Mandatory=$false, Position=0)][string]$BackupIvrScriptName = '_prompt_backup'
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

$promptBackupXml = @"
<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<ivrScript>
    <domainId>11111</domainId>
    <properties/>
    <modules>
        <incomingCall>
            <singleDescendant>3509F3706E8545F7BFF52431B1293B63</singleDescendant>
            <moduleName>Start</moduleName>
            <locationX>38</locationX>
            <locationY>47</locationY>
            <moduleId>B7C97F693F7C4B21A9977921EABFCDCD</moduleId>
            <data/>
        </incomingCall>
        <play>
            <ascendants>B7C97F693F7C4B21A9977921EABFCDCD</ascendants>
            <singleDescendant>82E81AC0D2D34BB997B366D3EAA68C05</singleDescendant>
            <moduleName>AllPrompts</moduleName>
            <locationX>137</locationX>
            <locationY>121</locationY>
            <moduleId>3509F3706E8545F7BFF52431B1293B63</moduleId>
            <data>
                <prompt>
$(
    $prompts = Get-Five9Prompt

    foreach ($prompt in $prompts)
    {
        Write-Verbose "$($MyInvocation.MyCommand.Name): Adding Prompt: '$($prompt.name)'"


@"
                    <filePrompt>
                        <promptData>
                            <promptSelected>true</promptSelected>
                            <prompt>
                                <name>$($prompt.name)</name>
                            </prompt>
                            <isRecordedMessage>false</isRecordedMessage>
                        </promptData>
                    </filePrompt>
"@
    }       
)  
                    <interruptible>false</interruptible>
                    <canChangeInterruptableOption>true</canChangeInterruptableOption>
                    <ttsEnumed>false</ttsEnumed>
                    <exitModuleOnException>false</exitModuleOnException>
                </prompt>
                <dispo>
                    <id>-17</id>
                    <name>Caller Disconnected</name>
                </dispo>
                <vivrPrompts>
                    <interruptible>false</interruptible>
                    <canChangeInterruptableOption>true</canChangeInterruptableOption>
                    <ttsEnumed>false</ttsEnumed>
                    <exitModuleOnException>false</exitModuleOnException>
                </vivrPrompts>
                <vivrHeader>
                    <interruptible>false</interruptible>
                    <canChangeInterruptableOption>true</canChangeInterruptableOption>
                    <ttsEnumed>false</ttsEnumed>
                    <exitModuleOnException>false</exitModuleOnException>
                </vivrHeader>
                <textChannelData>
                    <textPrompts>
                        <interruptible>false</interruptible>
                        <canChangeInterruptableOption>true</canChangeInterruptableOption>
                        <ttsEnumed>false</ttsEnumed>
                        <exitModuleOnException>false</exitModuleOnException>
                    </textPrompts>
                    <isUsedVivrPrompts>true</isUsedVivrPrompts>
                    <isTextOnly>true</isTextOnly>
                </textChannelData>
                <numberOfDigits>0</numberOfDigits>
                <terminateDigit>N/A</terminateDigit>
                <clearDigitBuffer>false</clearDigitBuffer>
                <collapsible>false</collapsible>
                <emailReplySubject>
                    <interruptible>false</interruptible>
                    <canChangeInterruptableOption>true</canChangeInterruptableOption>
                    <ttsEnumed>false</ttsEnumed>
                    <exitModuleOnException>false</exitModuleOnException>
                </emailReplySubject>
                <emailReplyBody>
                    <interruptible>false</interruptible>
                    <canChangeInterruptableOption>true</canChangeInterruptableOption>
                    <ttsEnumed>false</ttsEnumed>
                    <exitModuleOnException>false</exitModuleOnException>
                </emailReplyBody>
            </data>
        </play>
        <hangup>
            <ascendants>3509F3706E8545F7BFF52431B1293B63</ascendants>
            <moduleName>End</moduleName>
            <locationX>229</locationX>
            <locationY>46</locationY>
            <moduleId>82E81AC0D2D34BB997B366D3EAA68C05</moduleId>
            <data>
                <dispo>
                    <id>0</id>
                    <name>No Disposition</name>
                </dispo>
                <returnToCallingModule>true</returnToCallingModule>
                <errCode>
                    <isVarSelected>false</isVarSelected>
                    <integerValue>
                        <value>0</value>
                    </integerValue>
                </errCode>
                <errDescription>
                    <isVarSelected>false</isVarSelected>
                    <stringValue>
                        <value></value>
                        <id>0</id>
                    </stringValue>
                </errDescription>
                <overwriteDisposition>true</overwriteDisposition>
            </data>
        </hangup>
        <setVariable>
            <ascendants>95B3A38FAC184F94A5140685112D1400</ascendants>
            <singleDescendant>95B3A38FAC184F94A5140685112D1400</singleDescendant>
            <moduleName>ReadMe</moduleName>
            <locationX>136</locationX>
            <locationY>206</locationY>
            <moduleId>95B3A38FAC184F94A5140685112D1400</moduleId>
            <data>
                <expressions>
                    <variableName>note</variableName>
                    <isFunction>false</isFunction>
                    <constant>
                        <isVarSelected>false</isVarSelected>
                        <stringValue>
                            <value>The play module named AllPrompts contains all prompts on the domain.</value>
                            <id>0</id>
                        </stringValue>
                    </constant>
                </expressions>
                <expressions>
                    <variableName>note</variableName>
                    <isFunction>false</isFunction>
                    <constant>
                        <isVarSelected>false</isVarSelected>
                        <stringValue>
                            <value>To complete the backup click Actions &gt; Backup &gt; Choose the backup path &gt; Click Backup</value>
                            <id>0</id>
                        </stringValue>
                    </constant>
                </expressions>
                <expressions>
                    <variableName>note</variableName>
                    <isFunction>false</isFunction>
                    <constant>
                        <isVarSelected>false</isVarSelected>
                        <stringValue>
                            <value>You can then restore prompts on a different domain by creating a new IVR script in that domain and clicking Actions &gt; Restore &gt; Choose ZIP file from previous step</value>
                            <id>0</id>
                        </stringValue>
                    </constant>
                </expressions>
            </data>
        </setVariable>
    </modules>
    <modulesOnHangup>
        <startOnHangup>
            <singleDescendant>741FCCB0CE98480DBBDAB0149548FCFC</singleDescendant>
            <moduleName>StartOnHangup4</moduleName>
            <locationX>20</locationX>
            <locationY>10</locationY>
            <moduleId>788D7B536DE64EDAA22A24F736EB8A02</moduleId>
        </startOnHangup>
        <hangup>
            <ascendants>788D7B536DE64EDAA22A24F736EB8A02</ascendants>
            <moduleName>Hangup7</moduleName>
            <locationX>120</locationX>
            <locationY>10</locationY>
            <moduleId>741FCCB0CE98480DBBDAB0149548FCFC</moduleId>
            <data>
                <dispo>
                    <id>-17</id>
                    <name>Caller Disconnected</name>
                </dispo>
                <returnToCallingModule>true</returnToCallingModule>
                <errCode>
                    <isVarSelected>false</isVarSelected>
                    <integerValue>
                        <value>0</value>
                    </integerValue>
                </errCode>
                <errDescription>
                    <isVarSelected>false</isVarSelected>
                    <stringValue>
                        <value></value>
                        <id>0</id>
                    </stringValue>
                </errDescription>
                <overwriteDisposition>false</overwriteDisposition>
            </data>
        </hangup>
    </modulesOnHangup>
    <userVariables>
        <entry>
            <key>note</key>
            <value>
                <name>note</name>
                <description></description>
                <stringValue>
                    <value></value>
                    <id>0</id>
                </stringValue>
                <attributes>8</attributes>
                <isNullValue>true</isNullValue>
            </value>
        </entry>
    </userVariables>
    <multiLanguagesPrompts>
        <entry>
            <key>6EDD8CD369B4471F81D3DA58909A1FDC</key>
            <value>
                <promptId>6EDD8CD369B4471F81D3DA58909A1FDC</promptId>
                <name>ConfirmPromptWithoutVSR</name>
                <description>Default prompt for user input confirmation with disabled voice recognition</description>
                <type>AUDIO</type>
                <prompts>
                    <entry key="en-US">
                        <ttsPrompt>
                            <xml>H4sIAAAAAAAAANVT0UrDMBR931eEvK9xPslIOypMGAwVtyk+lbS9bsE0GUla17837bA23YYg+GDJ
Q3PO5ZyTexM6OxQCVaANVzLEk+AKI5CZyrnchnizvhvfYGQskzkTSkKIazB4Fo2o2QN7nwsoQNpo
hNxHmbWap6UFcwRaUDC5jR3xDbWwZAVEznra8JS0W7+iU3tmooRbZgBVzV+IQY43K0x6JsR3oWQY
hXILRT+WYXVsvPinxoYMmIFIh1s42LNaP2v62pfIVOV19KpKNxoLGvKpO2KLnWYhF8NQMmwCOd8F
WjHNWSrgV/0Zgl9i982Ik2T1skiWi/X8KV4mCSUe20t2McJ/nFyAHjUYg/AEI/6G7I4b5FamtIbM
BujB7kB/cHfD98e6a/xX8+2KHOm94E/oteYzCQQAAA==</xml>
                            <promptTTSEnumed>false</promptTTSEnumed>
                        </ttsPrompt>
                    </entry>
                </prompts>
                <defaultLanguage>en-US</defaultLanguage>
                <isPersistent>true</isPersistent>
            </value>
        </entry>
        <entry>
            <key>7AB41F56573348FCA5A1ACFA3CE32230</key>
            <value>
                <promptId>7AB41F56573348FCA5A1ACFA3CE32230</promptId>
                <name>ConfirmPrompt</name>
                <description>Default prompt for user input confirmation</description>
                <type>AUDIO</type>
                <prompts>
                    <entry key="en-US">
                        <ttsPrompt>
                            <xml>H4sIAAAAAAAAANVTUWvCMBB+91ccebeZexqSVhw4EMTB1A2fSrQ3DWsTyaXO/vulHXNttQwGe1jI
Q/J9ue++3CVidMpSOKIlZXTIBsENA9Rbkyi9C9lq+dC/Y0BO6kSmRmPICiQ2inqCDijfJilmqF3U
Az+EdM6qTe6QPoEKTKXejT3xDVWwlhlGPvWw5AWvts0TZ7VnmeZ4LwnhWK5Chrq/WjBeS8KbWQRv
WxHKYVa3RbIYU8P+ZWLiLaYlcsYdntxVrZ81m9pd5MYkRbQ2uW+NQ4vJ0F+xwi698E4zgreLwK9X
QRylVXKT4q/q0wa/xOZli+N48TKNZ9Pl5Gk8i2PBG2zNWaeF/9i5ABayALb2XweMhYNFImADBuoV
3F4R+Lk11uLWBfDo9mjflX/uVAbNTT3mlv1V48+HPNn42h9LoLssIgQAAA==</xml>
                            <promptTTSEnumed>false</promptTTSEnumed>
                        </ttsPrompt>
                    </entry>
                </prompts>
                <defaultLanguage>en-US</defaultLanguage>
                <isPersistent>true</isPersistent>
            </value>
        </entry>
        <entry>
            <key>B1A84ED84CDA41E68ED205D5B2AB20A3</key>
            <value>
                <promptId>B1A84ED84CDA41E68ED205D5B2AB20A3</promptId>
                <name>NoMatchPrompt</name>
                <description>Default prompt for NoMatch event</description>
                <type>AUDIO</type>
                <prompts>
                    <entry key="en-US">
                        <ttsPrompt>
                            <xml>H4sIAAAAAAAAAIWRQYvCMBCF7/6KkLvO7k0krSis4Fnd+2gHCZtOpTMV++83VqimXdmcku+F9x4z
bnkrg7lSLb7izH7OPqwhPlWF53NmD/vNdG6NKHKBoWLKbEtil/nEyYXw5ytQSaz5xMTjULX2x0ZJ
HqCDAfm8isITdZixpDxGL+66g+6Z/ujdvjE0tEYhc73fMks8PewsvIRAmuJgWMV5pfK1lmC7kqT+
OFhgoAxMeq500z+9/vdMvd+Jx6po821cS13TSY3nS6MzBx0e14G3fRwM5wDjQfSfopgs+RfRtLpi
LAIAAA==</xml>
                            <promptTTSEnumed>false</promptTTSEnumed>
                        </ttsPrompt>
                    </entry>
                </prompts>
                <defaultLanguage>en-US</defaultLanguage>
                <isPersistent>true</isPersistent>
            </value>
        </entry>
        <entry>
            <key>DC3D45DD9742457D93F4828905A9A140</key>
            <value>
                <promptId>DC3D45DD9742457D93F4828905A9A140</promptId>
                <name>NoInputPrompt</name>
                <description>Default prompt for NoInput event</description>
                <type>AUDIO</type>
                <prompts>
                    <entry key="en-US">
                        <ttsPrompt>
                            <xml>H4sIAAAAAAAAAIWRQYvCMBCF7/6KkHsdvS1LWnFhBc+7eh/toMV0Ip2p2H9vrVBNu7I5Je8b3ntM
3OJaenOhSorAqZ1PZ9YQ70Ne8CG1m99V8mGNKHKOPjCltiGxi2zi5Ex4+vZUEms2Me1xqFoVu1pJ
HkIneuTDsgVPqZMZS8ra6M87d9A944nebYu+pi8UMpf7LbXEyebHwksIxCkOhlVcoVS+1hJslhLV
HwcLDMjApNeVrvqn1/+esfc7uAt5k63NHpmDmiNhZZpQTx10YFwI3jZyMNwEjFfRD7Uw+uYbQw31
uC4CAAA=</xml>
                            <promptTTSEnumed>false</promptTTSEnumed>
                        </ttsPrompt>
                    </entry>
                </prompts>
                <defaultLanguage>en-US</defaultLanguage>
                <isPersistent>true</isPersistent>
            </value>
        </entry>
    </multiLanguagesPrompts>
    <multiLanguagesVIVRPrompts/>
    <multiLanguagesTextPrompts/>
    <multiLanguagesMenuChoices/>
    <multiLanguagesEwtAnnouncement/>
    <languages/>
    <functions/>
    <defaultLanguage>en-US</defaultLanguage>
    <defaultMethod>GET</defaultMethod>
    <defaultFetchTimeout>5</defaultFetchTimeout>
    <showLabelNames>true</showLabelNames>
    <defaultVivrTimeout>5</defaultVivrTimeout>
    <unicodeEncoding>false</unicodeEncoding>
    <useShortcut>false</useShortcut>
    <resetErrorCode>true</resetErrorCode>
    <showAllChannelPrompts>false</showAllChannelPrompts>
    <extContactFieldsInput>true</extContactFieldsInput>
    <extContactFieldsOutput>true</extContactFieldsOutput>
    <useIvrTimeZoneInAssignment>true</useIvrTimeZoneInAssignment>
    <timeoutInMilliseconds>3600000</timeoutInMilliseconds>
    <version>1200006</version>
</ivrScript>
"@

        $existingIvrScript = $null
        try
        {
            $existingIvrScript = Get-Five9IVRScript -NamePattern $BackupIvrScriptName
        }
        catch
        {

        }

        if ($existingIvrScript)
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Exporting all Five9 Prompts to existing IVR: '$($BackupIvrScriptName)'"
            Set-Five9IVRScript -Name $BackupIvrScriptName -XmlDefinition $promptBackupXml
        }
        else
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Exporting all Five9 Prompts to new IVR: '$($BackupIvrScriptName)'"
            New-Five9IVRScript -Name $BackupIvrScriptName -Description "backup of all Five9 prompts" -XmlDefinition $promptBackupXml
        }

        
    }
    catch
    {
        $_ | Write-PSFive9AdminError
		$_ | Write-Error
    }
}