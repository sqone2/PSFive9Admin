function Get-Five9DNCNumber
{
    <#
    .SYNOPSIS
    
        Function used to check whether phone number(s) are part of a DNC list
   
    .EXAMPLE
    
        Get-Five9DNCNumber -Number '8005551212'
    
        # Returns True or False depending on whether the number is on the DNC list
    
    .EXAMPLE
    
        Get-Five9DNCNumber -Number @('8005551212', '3215551212')
    
        # Returns whether each number is on the DNC list
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # One or more numbers to search for in the DNC list
        # You may include up to 50000 phone numbers in a request
        [Parameter(Mandatory=$true)][string[]]$Number
    )
    
    try
    {

Add-Type @"
public struct dncNumber {
    public string number;
    public bool DNC;
}
"@ -IgnoreWarnings

        Test-Five9Connection -ErrorAction: Stop

        if ($Number.Count -eq 1)
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Checking DNC for '$Number'."

            $response = $global:DefaultFive9AdminClient.checkDncForNumbers($Number)

            if ($response -eq $null)
            {
                return $false
            }
            else
            {
                return $true
            }

        }
        else
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Checking DNC for $($Number.Count) numbers." 

            $response = $global:DefaultFive9AdminClient.checkDncForNumbers($Number)
            
            $returnList = @()
            foreach ($num in $Number)
            {
                if ($num.Length -gt 5)
                {
                    $dncNumber = New-Object -TypeName dncNumber
                    $dncNumber.number = $num
                    [bool]$dncNumber.DNC = $($response -contains $num)

                    $returnList += $dncNumber
                }
            }

            return $returnList | sort number


        }
        
        

    }
    catch
    {
        throw $_
    }
}
