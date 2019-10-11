function Get-WEFLogInfo {
    param (
        [string]$WECServer,
        [string]$LogFile
    )
    
    $cmd1 = "wevtutil gl $LogFile"
    $cmd2 = "wevtutil gli $LogFile"

    if ($PSBoundParameters['WECServer']) {
        $res1 = Invoke-Command -ComputerName $WECServer -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd1
        $res2 = Invoke-Command -ComputerName $WECServer -ScriptBlock { Invoke-Expression $args[0] } -ArgumentList $cmd2
    } else {
        $res1 = Invoke-Expression $cmd1
        $res2 = Invoke-Expression $cmd2
    }

    $res1Parsed = New-Object psobject
    $res1 | ForEach-Object {
        $propsParsed = ($_ -split ': ').Trim()
        $res1Parsed | Add-Member NoteProperty $propsParsed[0] $propsParsed[1]
    }

    $res2Parsed = New-Object psobject
    $res2 | ForEach-Object {
        $propsParsed = ($_ -split ': ').Trim()
        $res2Parsed | Add-Member NoteProperty $propsParsed[0] $propsParsed[1]
    }
    
    $resObj = [PSCustomObject]@{
        LogCreation = [datetime]$res2Parsed.creationTime
        LogLastAccess = [datetime]$res2Parsed.lastAccessTime
        LogLastWrite = [datetime]$res2Parsed.lastWriteTime
        LogFilesize = $res2Parsed.fileSize
        LogNumberOfRecords = $res2Parsed.numberOfLogRecords
        LogChannelAccess = (ConvertFrom-SddlString $res1Parsed.channelAccess).DiscretionaryAcl
        LogChannelAccessSDDL = $res1Parsed.channelAccess
        LogFilePath = $res1Parsed.logFileName
        LogRetention = $res1Parsed.retention
        LogAutoBackup = $res1Parsed.autoBackup
        LogMaxSize = $res1Parsed.maxSize
    }

    return $resObj
}