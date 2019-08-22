function Get-WEFRuntimeStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$WECServer,

        [Parameter(Mandatory = $true)]
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

        $sourcesRaw = $res[5..$res.length]
        $sources = @()
        for ($i=0; $i -lt $sourcesRaw.length; $i+=4) {
            $sources += ,($sourcesRaw[$i..($i+3)])
        }

        if ($PSBoundParameters.SourceStatus){
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
                EventSources    = $sources.Count
                Active          = ($sources.ForEach({$_[1]}).Where({$_ -match '\sActive'})).Count
                Inactive        = ($sources.ForEach({$_[1]}).Where({$_ -match '\sInactive'})).Count
            }
        }
        
    }
    
    end {
        # return data
        return $out
    }
}