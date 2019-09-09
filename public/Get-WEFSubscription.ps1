function Get-WEFSubscription {
    [CmdletBinding()]
    param (
        [string]$WECServer,
        [string[]]$Subscription,
        [switch]$List,

        [ValidateSet('XML','Object')]
        [string]$Format
    )
    
    begin {
        # declare vars/call data
    }
    
    process {
        if ($PSBoundParameters.List) {
            $cmd = "wecutil es"
            $outList = Invoke-Command -ComputerName $WECServer -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd

            $out = $outList
        } elseif ($PSBoundParameters.Subscription) {
            $res = @()
            foreach ($sub in $Subscription) {
                $cmd = "wecutil gs $sub /f:XML"
                # if no wec server prompted, localhost
                if ($PSBoundParameters.WECServer) {
                    $res += Invoke-Command -ComputerName $WECServer -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd
                } else {
                    $res += Invoke-Expression $cmd
                }
            }
            
            if ($PSBoundParameters.Format -eq 'XML') {
                $out = $res
            } else { 
                foreach ($r in [xml]$res) {
                    $nonDomainSddl = try { (ConvertFrom-SddlString $r.Subscription.AllowedSourceNonDomainComputers).DiscretionaryAcl -join ', ' } catch {}
                    $domainSddl = try { (ConvertFrom-SddlString $r.Subscription.AllowedSourceDomainComputers).DiscretionaryAcl -join ', '  } catch {}

                    if ($PSBoundParameters.WECServer) {
                        $logInfo = Get-WEFLogInfo -WECServer $WECServer -LogFile $r.Subscription.LogFile
                    } else {
                        $logInfo = Get-WEFLogInfo -LogFile $r.Subscription.LogFile
                    }

                    $out = [PSCustomObject]@{
                        SubscriptionId                      = $r.Subscription.SubscriptionId
                        SubscriptionType                    = $r.Subscription.SubscriptionType           
                        Description                         = $r.Subscription.Description
                        Enabled                             = $r.Subscription.Enabled
                        ConfigurationMode                   = $r.Subscription.ConfigurationMode
                        Delivery                            = $null
                        Query                               = $r.Subscription.Query.'#cdata-section'
                        ReadExistingEvents                  = $r.Subscription.ReadExistingEvents
                        TransportName                       = $r.Subscription.TransportName
                        ContentFormat                       = $r.Subscription.ContentFormat
                        Locale                              = $r.Subscription.Locale
                        LogFile                             = $r.Subscription.LogFile
                        AllowedSourceNonDomainComputers     = $nonDomainSddl
                        AllowedSourceNonDomainComputersSDDL = $r.Subscription.AllowedSourceNonDomainComputers
                        AllowedSourceDomainComputers        = $domainSddl
                        AllowedSourceDomainComputersSDDL    = $r.Subscription.AllowedSourceDomainComputers
                        LogCreation                         = $logInfo.LogCreation
                        LogLastAccess                       = $logInfo.LogLastAccess
                        LogLastWrite                        = $logInfo.LogLastWrite
                        LogFilesize                         = $logInfo.LogFilesize
                        LogNumberOfRecords                  = $logInfo.LogNumberOfRecords
                        LogChannelAccess                    = $logInfo.LogChannelAccess
                        LogChannelAccessSDDL                = $logInfo.LogChannelAccessSDDL
                        LogFilePath                         = $logInfo.LogFilePath
                        LogRetention                        = $logInfo.LogRetention
                        LogAutoBackup                       = $logInfo.LogAutoBackup
                        LogMaxSize                          = $logInfo.LogMaxSize
                    } 

                    $deliveryObj = @()
                    if ($r.Subscription.Delivery.Mode -eq 'Push') {
                        $deliveryObj = [PSCustomObject]@{
                            Mode = $r.Subscription.Delivery.Mode
                            Batching = [PSCustomObject]@{
                                MaxItems = $r.Subscription.Delivery.Batching.MaxItems
                                MaxLatencyTime = $r.Subscription.Delivery.Batching.MaxLatencyTime
                            }
                            PushSettings = [PSCustomObject]@{
                                HeartBeatInterval = $r.Subscription.Delivery.PushSettings.Heartbeat.Interval
                            }
                        }
                    }
                    
                    $out.Delivery = $deliveryObj
                }
            }
        }
    }
    
    end {
        # return data
        return $out
    }
}