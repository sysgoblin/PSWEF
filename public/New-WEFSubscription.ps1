function New-WEFSubscription {
    # generate subscription from declarations/xpath
    [CmdletBinding()]
    param (
        [string]$WECServer,
        [string]$Name,

        [Parameter(ParameterSetName = 'Generate')]
        [string]$Query,

        [Parameter(ParameterSetName = 'Generate')]
        [ValidateSet('SourceInitiated','CollectorInitiated')]
        [string]$SubscriptionType = "SourceInitiated",

        [Parameter(ParameterSetName = 'Generate')]
        [string]$Description,
        
        [Parameter(ParameterSetName = 'Generate')]
        [ValidateSet("true", "false")]
        [string]$Enabled = "true",

        [Parameter(ParameterSetName = 'Generate')]
        [ValidateSet("Custom")]
        [string]$ConfigurationMode = "Custom",

        [Parameter(ParameterSetName = 'Generate')]
        [string]$Delivery = "Push",

        [Parameter(ParameterSetName = 'Generate')]
        [string]$ReadExistingEvents = "true",

        [Parameter(ParameterSetName = 'Generate')]
        [string]$ContentFormat = "Events",

        [Parameter(ParameterSetName = 'Generate')]
        [string]$LogFile = "test-sub",

        [Parameter(ParameterSetName = 'Generate')]
        [string]$AllowedSourceNonDomainComputers,

        [Parameter(ParameterSetName = 'Generate')]
        [string]$AllowedSourceDomainComputers = "O:NSG:NSD:(A;;GA;;;DC)(A;;GA;;;NS)(A;;GA;;;DD)",
        
        [Parameter(ParameterSetName = 'File')]
        [xml]$XMLFile
    )

    DynamicParam {
        if ($ConfigurationMode -eq 'Custom') {
            $att1 = New-Object -Type System.Management.Automation.ParameterAttribute
            $att1.Mandatory = $true
            $att1col = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
            $att1col.Add($att1)
            $dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("MaxItems", [Int32], $att1col)

            $att2 = New-Object -Type System.Management.Automation.ParameterAttribute
            $att2.Mandatory = $true
            $att2col = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
            $att2col.Add($att2)
            $dynParam2 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("MaxLatencyTime", [Int32], $att2col)

            $att3 = New-Object -Type System.Management.Automation.ParameterAttribute
            $att3.Mandatory = $true
            $att3col = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
            $att3col.Add($att3)
            $dynParam2 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("Heartbeat", [Int32], $att3col)
            
            $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add("MaxItems", $dynParam1)
            $paramDictionary.Add("MaxLatencyTime", $dynParam2)
            $paramDictionary.Add("Heartbeat", $dynParam3)
        }

        return $paramDictionary
    }

    begin {

    }

    process {
        # create xml
        [xml]$xml = New-Object System.Xml.XmlDocument
        $subscriptionElem = $xml.CreateElement("Subscription") # instrumentationManifest node
        $subscriptionElem.SetAttribute("xmlns","http://schemas.microsoft.com/2006/03/windows/events/subscription")
        $xml.AppendChild($subscriptionElem) # append root node

        # add child nodes
        $subscriptionElem.AppendChild($xml.CreateElement("SubscriptionId"))
        $subscriptionElem.AppendChild($xml.CreateElement("SubscriptionType"))
        $subscriptionElem.AppendChild($xml.CreateElement("Description"))
        $subscriptionElem.AppendChild($xml.CreateElement("Enabled"))
        $subscriptionElem.AppendChild($xml.CreateElement("Uri"))
        $subscriptionElem.AppendChild($xml.CreateElement("ConfigurationMode"))
        $del = $subscriptionElem.AppendChild($xml.CreateElement("Delivery"))
        $bat = $del.AppendChild($xml.CreateElement("Batching"))
        $bat.AppendChild($xml.CreateElement("MaxItems"))
        $bat.AppendChild($xml.CreateElement("MaxLatencyTime"))
        $pus = $del.AppendChild($xml.CreateElement("PushSettings"))
        $pus.AppendChild($xml.CreateElement("Heartbeat"))
        $subscriptionElem.AppendChild($xml.CreateElement("Query"))
        $subscriptionElem.AppendChild($xml.CreateElement("ReadExistingEvents"))
        $subscriptionElem.AppendChild($xml.CreateElement("TransportName"))
        $subscriptionElem.AppendChild($xml.CreateElement("ContentFormat"))
        $loc = $subscriptionElem.AppendChild($xml.CreateElement("Locale"))
        $loc.SetAttribute("Language", "en-US")
        $subscriptionElem.AppendChild($xml.CreateElement("LogFile"))
        $subscriptionElem.AppendChild($xml.CreateElement("AllowedSourceNonDomainComputers"))
        $subscriptionElem.AppendChild($xml.CreateElement("AllowedSourceDomainComputers"))

        # set values
        $xml.Subscription.SubscriptionType = $SubscriptionType
        $xml.Subscription.Description = $Description
        $xml.Subscription.Enabled = $Enabled
        $xml.Subscription.Uri = "http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog"
        $xml.Subscription.ConfigurationMode = $ConfigurationMode
        $xml.Subscription.Delivery.SetAttribute("Mode", $Delivery)
        $xml.Subscription.ReadExistingEvents = $ReadExistingEvents
        $xml.Subscription.TransportName = "http"
        $xml.Subscription.ContentFormat = $ContentFormat
        $xml.Subscription.LogFile = $LogFile
        $xml.Subscription.AllowedSourceNonDomainComputers = $AllowedSourceNonDomainComputers
        $xml.Subscription.AllowedSourceDomainComputers = $AllowedSourceDomainComputers

        $xml.Subscription.Query = $Query
    }

    end {}
}