function Export-WEFManifest {
    [CmdletBinding()]
    param (
        [string]$Path,
        [string]$ExportPath
    )
    
    begin {
        # get files and group LogFile
        $subscriptions = gci $Path *.xml

        # parse log file name to get channel name (naming convention "channel-logname")
        $subXml = $subscriptions | % {
            [xml]$x = gc $_.fullname
            [PSCustomObject]@{
                Subscription = $x.Subscription.SubscriptionId
                XmlFile = $_.FullName
                LogFile = $x.Subscription.LogFile
                Provider = ($x.Subscription.LogFile -split '-')[0]
            }
        }

        # validation
        # over 7 channels
        $over7 = $subXml | group Provider | ? Count -gt 7
        if ($over7) {
            $ch = $over7.Name
            $chM = $over7.group.Subscription
            Write-Error "Provider $ch over 7 channels $($chM -join ', ')"
            exit
        }

        # channel names valid (provider-channel-name)
        # duplicate channel names
    }
    
    process {
        # generate nodes from nested object/ht??

        # generate xml
        [xml]$xml = New-Object System.Xml.XmlDocument
        $dec = $xml.CreateXmlDeclaration("1.0",$null,$null)

        $xml.AppendChild($dec) # declaration

        $instrumentationManifest = $xml.CreateElement("instrumentationManifest") # instrumentationManifest node
        $att1 = $xml.CreateAttribute("xsi", "schemaLocation", "http://www.w3.org/2001/XmlSchema-instance")
        $att1.Value = "http://schemas.microsoft.com/win/2004/08/events eventman.xsd"
        $instrumentationManifest.Attributes.Append($att1) # to append xsi to schemaLocation
        $instrumentationManifest.SetAttribute("xmlns","http://schemas.microsoft.com/win/2004/08/events")
        $instrumentationManifest.SetAttribute("xmlns:win","http://manifests.microsoft.com/win/2004/08/windows/events")
        $instrumentationManifest.SetAttribute("xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance")
        $instrumentationManifest.SetAttribute("xmlns:xs","http://www.w3.org/2001/XMLSchema")
        $instrumentationManifest.SetAttribute("xmlns:trace","http://schemas.microsoft.com/win/2004/08/events/trace")
        $xml.AppendChild($instrumentationManifest) # append root node

        # add child nodes
        $instrumentation = $instrumentationManifest.AppendChild($xml.CreateElement("instrumentation"))
        $events = $instrumentation.AppendChild($xml.CreateElement("events"))

        # add each provider node and children
        # foreach
        $i = 0 # number for chid
        foreach ($prov in $($subXml | group Provider | sort Name)) {
            $i++
            $pName = $prov.Name
            
            $provider = $xml.CreateElement("provider")
            $provider.SetAttribute("name","$pName")
            $guid = (New-Guid).guid # guid for provider
            $provider.SetAttribute("guid", "{$guid}")
            $provider.SetAttribute("symbol","$($pName)_EVENTS")
            $provider.SetAttribute("resourceFileName","C:\Windows\system32\CustomEventChannels.dll")
            $provider.SetAttribute("messageFileName","c:\Windows\system32\CustomEventChannels.dll")
            $events.AppendChild($provider)

            $provEvents = $provider.AppendChild($xml.CreateElement("events"))
            $event = $xml.CreateElement("event")
            $event.SetAttribute("symbol","DUMMY_EVENT")
            $event.SetAttribute("value","100")
            $event.SetAttribute("version","0")
            $event.SetAttribute("template","DUMMY_TEMPLATE")
            $event.SetAttribute("message",'$(string.Custom Forwarded Events.event.100.message)')
            $provEvents.AppendChild($event)

            $channels = $provider.AppendChild($xml.CreateElement("channels"))
            $importChannel = $xml.CreateElement("importChannel")
            $importChannel.SetAttribute("name","System")
            $importChannel.SetAttribute("chid","C$i")
            $channels.AppendChild($importChannel)

            # foreach channel in provider (max 7)
            foreach ($pch in $prov.group){
                $channel = $xml.CreateElement("channel")
                $channel.SetAttribute("name",$pch.LogFile)
                $channel.SetAttribute("chid",$pch.LogFile)
                $channel.SetAttribute("symbol",($pch.LogFile -replace '-','_')) # replace '-' with '_'
                $channel.SetAttribute("type", "Operational")
                $channel.SetAttribute("enabled","true")
                $channels.AppendChild($channel)
            }

            $templates = $provider.AppendChild($xml.CreateElement("templates"))
            $template = $xml.CreateElement("template")
            $template.SetAttribute("tid","DUMMY_TEMPLATE")
            $templates.AppendChild($template)

            # foreach
            $data = $xml.CreateElement("data")
            $data.SetAttribute("name","Prop_UnicodeString")
            $data.SetAttribute("inType","win:UnicodeString")
            $data.SetAttribute("outType","xs:string")
            $data1 = $xml.CreateElement("data")
            $data1.SetAttribute("name","PropUInt32")
            $data1.SetAttribute("inType","win:UInt32")
            $data1.SetAttribute("outType","xs:unsignedInt")
            $template.AppendChild($data)
            $template.AppendChild($data1)
        }

        $localization = $instrumentationManifest.AppendChild($xml.CreateElement("localization"))
        $resources = $xml.CreateElement("resources")
        $resources.SetAttribute("culture","en-US")
        $localization.AppendChild($resources)

        $stringTable = $resources.AppendChild($xml.CreateElement("stringTable"))
        $string = $xml.CreateElement("string")
        $string.SetAttribute("id","level.Informational")
        $string.SetAttribute("value","Information")
        $string1 = $xml.CreateElement("string")
        $string1.SetAttribute("id","channel.System")
        $string1.SetAttribute("value","System")
        $string2 = $xml.CreateElement("string")
        $string2.SetAttribute("id","Publisher.EventMessage")
        $string2.SetAttribute("value",'Prop_UnicodeString=%1;%n&#xA;                  Prop_UInt32=%2;%n')
        $string3 = $xml.CreateElement("string")
        $string3.SetAttribute("id","Custom Forwarded Events.event.100.message")
        $string3.SetAttribute("value",'Prop_UnicodeString=%1;%n&#xA;                  Prop_UInt32=%2;%n')
        $stringTable.AppendChild($string)
        $stringTable.AppendChild($string1)
        $stringTable.AppendChild($string2)
        $stringTable.AppendChild($string3)
    }
    
    end {
        # output results
        $xml.save($ExportPath)
    }
}

# end
# 	<localization>
# 		<resources culture="en-US">
# 			<stringTable>
# 				<string id="level.Informational" value="Information"></string>
# 				<string id="channel.System" value="System"></string>
# 				<string id="Publisher.EventMessage" value="Prop_UnicodeString=%1;%n&#xA;                  Prop_UInt32=%2;%n"></string>
# 				<string id="Custom Forwarded Events.event.100.message" value="Prop_UnicodeString=%1;%n&#xA;                  Prop_UInt32=%2;%n"></string>
# 			</stringTable>
# 		</resources>
# 	</localization>
# </instrumentationManifest>