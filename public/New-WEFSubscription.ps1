function New-WEFSubscription {
    # generate subscription file from declarations/xpath
    [CmdletBinding()]
    param (
        [string]$WECServer,
        [string]$Name,
        [string]$Query,
        [ValidateSet('SourceInitiated','CollectorInitiated')]
        [string]$SubscriptionType = "SourceInitiated",
        [string]$Description,
        [ValidateSet("true", "false")]
        [string]$Enabled = "true",
        [ValidateSet("Custom")]
        [string]$ConfigurationMode = "Custom",
        [string]$Delivery = "Push",
        [string]$ReadExistingEvents = "true",
        [string]$ContentFormat = "Events",
        [string]$LogFile = "test-sub",
        [string]$AllowedSourceNonDomainComputers,
        [string]$AllowedSourceDomainComputers = "O:NSG:NSD:(A;;GA;;;DC)(A;;GA;;;NS)(A;;GA;;;DD)",
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
    )

    DynamicParam {
        if ($ConfigurationMode -eq 'Custom') {
            $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
            $att = New-Object -Type System.Management.Automation.ParameterAttribute
            $att.Mandatory = $true
            $attCol = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
            $attCol.Add($att)

            $dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("MaxItems", [Int32], $attCol)
            $dynParam2 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("MaxLatencyTime", [Int32], $attCol)
            $dynParam3 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("Heartbeat", [Int32], $attCol)

            $paramDictionary.Add("MaxItems", $dynParam1)
            $paramDictionary.Add("MaxLatencyTime", $dynParam2)
            $paramDictionary.Add("Heartbeat", $dynParam3)
        }
        return $paramDictionary
    }

    begin {
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
    }

    process {
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

    end {
        $xml.Save($Path)
    }
}