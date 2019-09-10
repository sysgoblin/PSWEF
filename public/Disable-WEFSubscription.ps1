function Disable-WEFSubscription {
    [CmdletBinding()]
    param (
        [string]$WECServer,
        [string]$Subscription
    )
    
    begin {
    }
    
    process {
        $cmd = "wecutil ss $Subscription /e:false"

        if ($PSBoundParameters.WECServer) {
            Invoke-Command -ComputerName $WECServer -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd
        } else {
            Invoke-Expression $cmd
        }
    }
    
    end {
    }
}