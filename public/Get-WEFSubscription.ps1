function Get-WEFSubscription {
    [CmdletBinding()]
    param (
        [string]$WECServer,
        [string]$Subscription,
        [switch]$List,

        [ValidateSet('XML','Object')]
        [string]$Format
    )
    
    begin {
        # declare vars/call data
    }
    
    process {
        # create cmd
        $cmd = "wecutil"

        if ($PSBoundParameters.Subscription) {
            # if subscription specified return config
            $cmd += " gs $Subscription /f:XML"
        } elseif ($PSBoundParameters.List) {
            # if list, enum subscriptions
            $cmd += " es"
        } else {
            Write-Error "Please specify subscription ID or -List"
        }
        # if no wec server prompted, localhost

        if ($PSBoundParameters.WECServer) {
            $res = Invoke-Command -ComputerName $WECServer -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd
        } else {
            $res = Invoke-Expression $cmd
        }

        if ($PSBoundParameters.Format -eq 'XML') {
            $out = $res
        } else { 
            [xml]$res = $res
            $out = [PSCustomObject]@{
                SubscriptionId                  = $res.Subscription.SubscriptionId
                SubscriptionType                = $res.Subscription.SubscriptionType           
                Description                     = $res.Subscription.Description
                Enabled                         = $res.Subscription.Enabled
                ConfigurationMode               = $res.Subscription.ConfigurationMode
                Delivery                        = $null
                Query                           = $res.Subscription.Query.'#cdata-section'
                ReadExistingEvents              = $res.Subscription.ReadExistingEvents
                TransportName                   = $res.Subscription.TransportName
                ContentFormat                   = $res.Subscription.ContentFormat
                Locale                          = $res.Subscription.Locale
                LogFile                         = $res.Subscription.LogFile
                AllowedSourceNonDomainComputers = $res.Subscription.AllowedSourceNonDomainComputers
                AllowedSourceDomainComputers    = $res.Subscription.AllowedSourceDomainComputers
            } 

            $deliveryObj = @()
            if ($res.Subscription.Delivery.Mode -eq 'Push') {
                $deliveryObj = [PSCustomObject]@{
                    Mode = $res.Subscription.Delivery.Mode
                    Batching = [PSCustomObject]@{
                        MaxItems = $res.Subscription.Delivery.Batching.MaxItems
                        MaxLatencyTime = $res.Subscription.Delivery.Batching.MaxLatencyTime
                    }
                    PushSettings = [PSCustomObject]@{
                        HeartBeatInterval = $res.Subscription.Delivery.PushSettings.Heartbeat.Interval
                    }
                }
            }
            
            $out.Delivery = $deliveryObj
        }
    }
    
    end {
        # return data
        return $out
    }
}