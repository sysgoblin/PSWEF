function Disable-WEFSubscription {
<#
.SYNOPSIS
Disable specified Windows Event Forwarding subscription.

.DESCRIPTION
Disable specified Windows Event Forwarding subscription.

.PARAMETER Server
The remote Windows Event Collector server

.PARAMETER Subscription
The subscription to disable

.EXAMPLE
Disable-WEFSubscription -Server WECSVR01 -Subscription Example-Subscription
Disables the subscription "Example-Subscription" on the Windows Event Collector server WECSVR01
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Server,

        [Parameter(Mandatory = $true)]
        [string]$Subscription
    )

    $cmd = "wecutil ss $Subscription /e:false"

    if ($PSBoundParameters.Server) {
        Invoke-Command -ComputerName $Server -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd
    } else {
        Invoke-Expression $cmd
    }
}