function Get-WEFRuntimeStatus {
    [CmdletBinding()]
    param (
        [string]$WECServer,
        [string]$Subscription,
        [switch]$SourceStatus
    )
    
    begin {
        # declare vars
    }
    
    process {
        $cmd = "wecutil gr $Subscription"
        # get subscription runtime status
        if ($PSBoundParameters.WECServer) {
            $res = Invoke-Command -ComputerName $WECServer -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd
        } else {
            $res = Invoke-Expression $cmd
        }

        if ($PSBoundParameters.SourceStatus) {
            $sourcesRaw = $res[5..$res.length]
            $sources = @()
            for ($i=0; $i -lt $sourcesRaw.length; $i+=4) {
            $sources += ,($sourcesRaw[$i..($i+3)])
            }

            $out = foreach ($s in $sources) {
                [PSCustomObject]@{
                    Source          = $s[0].Trim()
                    RunTimeStatus   = ($s[1] -replace 'RunTimeStatus: ').Trim()
                    LastError       = ($s[2] -replace 'LastError: ').Trim()
                    LastHeartbeat   = ($s[3] -replace 'LastHeartbeatTime: ').Trim()
                }
            }
        } else {
            $out = [PSCustomObject]@{
                Subscription    = ($res[1] -replace 'Subscription: ').Trim()
                RunTimeStatus   = ($res[2] -replace 'RunTimeStatus: ').Trim()
                LastError       = ($res[3] -replace 'LastError: ').Trim()
            }
        }
    }
    
    end {
        # return data
        return $out
    }
}