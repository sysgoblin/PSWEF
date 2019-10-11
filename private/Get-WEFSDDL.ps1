function Get-WEFSDDL {
    # generate SDDL for wef use
    # https://itconnect.uw.edu/wares/msinf/other-help/understanding-sddl-syntax/
    # https://docs.microsoft.com/en-us/windows/win32/secauthz/sid-strings
    # sddl for group contains SID
    [CmdletBinding()]
    param (
        [string[]]$ADGroups,
        [switch]$IncludeNetworkService
    )
    
    begin {
        # validate groups
    }
    
    process {
        # get sid of each group
        $sids = @()
        $ADGroups | % {
            $sids += (Get-ADGroup $_).SID.Value
        }
        # generate sddl string part
        $sddls = @()
        $sids | % {
            $s = $_
            $sddls += "(A;;GA;;;$s)"
        }
        # concat
        $sddl = "O:NSG:NSD:" + ($sddls -join '')
    }
    
    end {
        # return string
        return $sddl
    }
}