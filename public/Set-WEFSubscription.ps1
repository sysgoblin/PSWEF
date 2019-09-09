function Set-WEFSubscription {
    [CmdletBinding()]
    param (
        [string]$WECServer,
        [string]$Subscription,
        [ValidateSet('True', 'False')]
        [string]$Retention,
        [ValidateSet('True', 'False')]
        [string]$AutoBackup,
        [ValidateRange(0,1600)]
        [int]$MaxSize
    )

    process {
        # check proposed config
        $cmd = "wevtutil sl $sub"

        if ($PSBoundParameters['Retention']) { $cmd += " /rt:$Retention"}
        if ($PSBoundParameters['AutoBackup']) { $cmd += " /ab:$AutoBackup"}
        if ($PSBoundParameters['MaxSize']) { 
            $size = $MaxSize * 1e+6
            $cmd += " /ms:$size"
        }

        # if no wec server prompted, localhost
        if ($PSBoundParameters.WECServer) {
            $res += Invoke-Command -ComputerName $WECServer -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd
        } else {
            $res += Invoke-Expression $cmd
        }
    }
}