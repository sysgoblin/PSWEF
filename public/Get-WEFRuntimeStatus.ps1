function Get-WEFRuntimeStatus {
<#
.SYNOPSIS
Return status of Subscription.

.DESCRIPTION
Return status of subscription including state, number of active sources and more. Optionally can include status of all sources.

.PARAMETER Server
The remote Windows Event Collector server

.PARAMETER Subscription
The subscription to return the runtime status of

.PARAMETER SourceStatus
Switch to show status of all sources

.EXAMPLE
PS C:\> Get-WEFRuntimeStatus -Subscription Example-Subscription

Subscription  : Example-Subscription
RunTimeStatus : Enabled
LastError     : 0
EventSources  : 120
Active        : 80
Inactive      : 40

Return status of scubscription including number of sources and count of active/inactive

.EXAMPLE
PS C:\> Get-WEFRuntimeStatus -Subscription Example-Subscription

Subscription  : Example-Subscription
RunTimeStatus : Enabled
LastError     : 0
EventSources  : 120
Active        : 80
Inactive      : 40

Return status of scubscription including number of sources and count of active/inactive

.EXAMPLE
PS C:\> Get-WEFRuntimeStatus -Subscription Example-Subscription -SourceStatus |  Select-Object Name, RunTimeStatus, LastHeartbeatTime

Name    RunTimeStatus LastHeartbeatTime
----    ------------- -----------------
Comp01  Enabled       2010-12-12 01:01:01

Return name, status and last heartbeat of all sources for Example-Subscription
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Server,

        [Parameter(Mandatory = $true,
        Position = 0)]
        [string]$Subscription,

        [Parameter(Mandatory = $false)]
        [switch]$SourceStatus
    )

    $cmd = "wecutil gr $Subscription"
    # get subscription runtime status
    if ($PSBoundParameters.Server) {
        $raw = Invoke-Command -ComputerName $Server -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd
    } else {
        $raw = Invoke-Expression $cmd
    }

    $res = ($raw -join "`n")

    $pattern = '(?<=\n)\t{2}(?!\t)(.+)\n\t{3}RunTimeStatus: (.+)\n\t{3}LastError: (.+)(?:\n\t{3}ErrorMessage: ((?:\n|.)+?)\n\t{3}ErrorTime: (.+)\n\t{3}NextRetryTime: (.+))?(?:\n\t{3}LastHeartbeatTime: (.+)|$)'
    $props = @{
        Property =  @{Name='Name';Expression={$arr[0]}},
                    @{Name='RunTimeStatus';Expression={$arr[1]}},
                    @{Name='LastError';Expression={[int]$arr[2]}},
                    @{Name='ErrorMessage';Expression={
                        $msg = ([xml]$arr[3]).WSManFault.Message
                        if($msg -is [string]) {$msg}
                        else {$msg.ProviderFault.ProviderError.'#text'}
                    }},
                    @{Name='ErrorTime';Expression={[datetime]$arr[4]}},
                    @{Name='NextRetryTime';Expression={[datetime]$arr[5]}},
                    @{Name='LastHeartbeatTime';Expression={[datetime]$arr[6]}}
    }


    $sources = [regex]::Matches($res,$pattern,'Multiline') | % {
        $arr = $_.Groups | select -skip 1 -exp value
        5 | select @props
    }

    if ($PSBoundParameters.SourceStatus){
        $sources
    } else {
        $subPattern = 'Subscription: (.+)\n\t{1}RunTimeStatus: (.+)\n\t{1}LastError: (.+)$'
        $props = @{
            Property =  @{Name='Subscription';Expression={$arr[0]}},
                        @{Name='RunTimeStatus';Expression={$arr[1]}},
                        @{Name='LastError';Expression={[int]$arr[2]}},
                        @{Name='EventSources';Expression={$sources.count}},
                        @{Name='Active';Expression={$sources.Where({$_.RunTimeStatus -eq 'Active'}).Count}},
                        @{Name='Inactive';Expression={$sources.Where({$_.RunTimeStatus -eq 'Inactive'}).Count}}
        }

        [regex]::Matches($res,$subPattern,'Multiline') | % {
            $arr = $_.Groups | select -skip 1 -exp value
            5 | select @props
        }
    }
}