function Set-WEFEventLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Server,
        [Parameter(Mandatory = $true)]
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
        if ($PSBoundParameters.Server) {
            $res += Invoke-Command -ComputerName $Server -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd
        } else {
            $res += Invoke-Expression $cmd
        }
    }
}