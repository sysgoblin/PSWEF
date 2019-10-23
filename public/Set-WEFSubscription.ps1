function Set-WEFSubscription {
    [CmdletBinding()]
    param (
        [string]$Server,
        [string]$Subscription,

        # update from config file
        [string]$ConfigurationFile,
        # description of subscription /d:
        [string]$Description,
        # configuration mode type, dont declare custom /cm:
        [ValidateSet('Normal','MinLatency','MinBandwidth')]
        [switch]$ConfigurationMode,
        # query /q:
        [string]$Query,
        # format /cf:
        [ValidateSet('Events','RenderedText')]
        [string]$Format,
        # read existing events /ree:
        [ValidateSet('True','False')]
        [string]$ReadExistingEvents,

        # custom config options
        # delivery mode /dm:
        [Parameter(ParameterSetName = 'Custom')]
        [ValidateSet('Push','Pull')]
        [string]$DeliveryMode,
        # max items /dmi:
        [Parameter(ParameterSetName = 'Custom')]
        [int]$DeliveryMaxItems,
        # max latency /dmlt:
        [Parameter(ParameterSetName = 'Custom')]
        [int]$DeliveryMaxLatency,
        # heartbeat interval /hi:
        [Parameter(ParameterSetName = 'Custom')]
        [int]$HeartbeatInterval,

        #transport type
        [ValidateSet('http','https')]
        [string]$Transport
        # event source

    )

    $cmd = "wecutil ss $Subscription "

    if (($PSCmdlet.ParameterSetName -eq 'Custom') -and !($PSBoundParameters['ConfigurationMode'])) {
        $cmd += "/cm:Custom "
    } elseif ((($PSCmdlet.ParameterSetName -eq 'Custom') -and $PSBoundParameters['ConfigurationMode'])) {
        Write-Error "Cannot have custom configuration options and standard configuration option declared."
        throw
    }

    switch ($PSBoundParameters.Keys) {
        ConfigurationFile   { $cmd += "/c:$ConfigurationFile " }
        Description         { $cmd += "/d:$Description " }
        Query               { $cmd += "/q:$Query " }
        Format              { $cmd += "/cf:$Format " }
        ReadExistingEvents  { $cmd += "/ree:$ReadExistingEvents " }
        # custom
        DeliveryMode        { $cmd += "/dm:$DeliveryMode " }
        DeliveryMaxItems    { $cmd += "/dmi:$DeliveryMaxItems " }
        DeliveryMaxLatency  { $cmd += "/dmlt:$DeliveryMaxLatency " }
        HeartbeatInterval   { $cmd += "/hi:$HeartbeatInterval " }
    }

    if ($PSBoundParameters['ReadExistingEvents']) {
        $cmd += "/ree:$ReadExistingEvents "
    }


    if ($PSBoundParameters['Server']) {
        try {
            $res += Invoke-Command -ComputerName $Server -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd
            Write-Output "Updated $Subscription"
        } catch {
            Write-Error "Error updating $Subscription"
            $_.Exception.Messaage
            throw
        }
    } else {
        try {
            $res += Invoke-Expression $cmd
            Write-Output "Updated $Subscription"
        } catch {
            Write-Error "Error updating $Subscription"
            $_.Exception.Messaage
            throw
        }
    }
}