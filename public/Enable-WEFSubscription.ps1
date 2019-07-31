function Enable-WEFSubscription {
    [CmdletBinding()]
    param (
        [string]$WECServer,
        [string]$Subscription
    )
    
    begin {
    }
    
    process {
        $cmd = "wecutil ss $Subscription /e:true"

        if ($PSBoundParameters.WECServer) {
            Invoke-Command -ComputerName $WECServer -ScriptBlock { $args[0] } -ArgumentList $cmd
        } else {
            Invoke-Expression $cmd
        }
    }
    
    end {
    }
}