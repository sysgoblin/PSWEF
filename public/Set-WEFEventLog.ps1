function Set-WEFEventLog {
<#
.SYNOPSIS
Set configuration options for a Windows Event Subscription log

.DESCRIPTION
Set configuration options for a Windows Event Subscription log

.PARAMETER Server
The remote Windows Event Collector server

.PARAMETER Subscription
The subscription which log is to be configured

.PARAMETER Retention
Set the retention of the log to true or false

.PARAMETER AutoBackup
Set the automatic backup of the log to true or false

.PARAMETER MaxSize
Set the maximum size of the log file in MB (maximum is 1600 MB)

.EXAMPLE
Set-WEFEventLog -Subscription Example-Subscription -Retention True

Enable retention for Example-Subscription
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Server,
        [Parameter(Mandatory = $true,
        ValueFromPipelineByPropertyName)]
        [string]$LogFile,
        [ValidateSet('True', 'False')]
        [string]$Retention,
        [ValidateSet('True', 'False')]
        [string]$AutoBackup,
        [ValidateRange(0,1600)]
        [int]$MaxSize
    )

    process {
        # check proposed config
        $cmd = "wevtutil sl $LogFile"

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