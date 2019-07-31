function Create-WEFSubscription {
    # generate subscription from declarations/xpath
    [CmdletBinding()]
    param (
        [string]$WECServer,
        [string]$Name,

        [Parameter(ParameterSetName = 'Generate')]
        [string]$Xpath,

        [Parameter(ParameterSetName = 'File')]
        [xml]$XMLFile
    )
    
    begin {
    }
    
    process {
    }
    
    end {
    }
}