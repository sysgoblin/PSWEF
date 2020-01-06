function Get-WEFSubscription {
<#
.SYNOPSIS
Get details of Windows Event Subscription

.DESCRIPTION
Return details on subscription including type, query, delivery mode, transport method, log information and more.

.PARAMETER Server
The remote Windows Event Collector server

.PARAMETER Subscription
The subscription to return information on

.PARAMETER List
List all subscriptions available

.PARAMETER SubscriptionXML
Return XML of subscription

.EXAMPLE
Get-WEFSubscription -Subscription Example-Subscription

Return subscription data on Example-Subscription
#>

    [CmdletBinding()]
    param (
        [string]$Server,

        [Parameter(Mandatory = $false,
        Position = 0)]
        [string]$Subscription,

        [switch]$List,

        [switch]$SubscriptionXML
    )

    if ($PSBoundParameters.List) {
        $cmd = "wecutil es"

        if ($PSBoundParameters.Server) {
            $outList = Invoke-Command -ComputerName $Server -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd
        } else {
            $outList = Invoke-Expression $cmd
        }

        $out = $outList
    } elseif ($PSBoundParameters.Subscription) {
        $cmd = "wecutil gs $Subscription /f:XML"
        # if no wec server prompted, localhost
        if ($PSBoundParameters.Server) {
            $res = Invoke-Command -ComputerName $Server -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd
        } else {
            $res = Invoke-Expression $cmd
        }

        if ($PSBoundParameters.SubscriptionXML) {
            $out = $res
        } else {
            $r = [xml]$res

            $nonDomainSddl = try { (ConvertFrom-SddlString $r.Subscription.AllowedSourceNonDomainComputers).DiscretionaryAcl } catch {}
            $domainSddl = try { (ConvertFrom-SddlString $r.Subscription.AllowedSourceDomainComputers).DiscretionaryAcl } catch {}

            if ($PSBoundParameters.Server) {
                $logInfo = Get-WEFLogInfo -Server $Server -LogFile $r.Subscription.LogFile
            } else {
                $logInfo = Get-WEFLogInfo -LogFile $r.Subscription.LogFile
            }

            $out = [PSCustomObject]@{
                SubscriptionId                      = $r.Subscription.SubscriptionId
                SubscriptionType                    = $r.Subscription.SubscriptionType
                Description                         = $r.Subscription.Description
                Enabled                             = $r.Subscription.Enabled
                ConfigurationMode                   = $r.Subscription.ConfigurationMode
                Delivery                            = @($r.Subscription.Delivery | select mode, batching, pushsettings)
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

    return $out
}