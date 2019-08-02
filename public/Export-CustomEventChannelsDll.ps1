function Export-CustomEventChannelsDll {
    [CmdletBinding()]
    param (
        [string]$SourceManifest,
        [string]$SDKSource = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.15063.0\x64",
        [string]$CSCSource = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319",
        [string]$Path
    )
    
    begin {
        # validate paths
        # test dependencies
        # copy source manifest to local dir if on net share
    }
    
    process {
        # make temp dir to work in
        $origPath = pwd
        mkdir "$Path\dlltemp\" > $null
        cd "$Path\dlltemp"

        & "$SDKSource\mc.exe" $SourceManifest > $null
        & "$SDKSource\mc.exe" -css CustomEventChannels.DummyEvent $SourceManifest > $null
        & "$SDKSource\rc.exe" CustomEventChannels.rc > $null
        & "$CSCSource\csc.exe" /win32res:CustomEventChannels.res /unsafe /target:library /out:CustomEventChannels.dll C:CustomEventChannels.cs > $null

        mv CustomEventChannels.dll $Path\CustomEventChannels.dll -Force
        cd $origPath
        rmdir "$Path\dlltemp\" -Recurse -Force
    }
    
    end {
        # output deets
    }
}