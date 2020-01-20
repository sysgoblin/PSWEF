# output dir
$location = "c:\temp\"

# get all subscriptions and query xml
$subNames = Get-WEFSubscription -List
# get all provider information
$allProviders = Get-WinEvent -ListProvider *

# for each sub
$subNames | % {
    # get sub details
    $sub = Get-WEFSubscription $_
    $subid = $sub.SubscriptionId
    [xml]$xml = $sub.Query

    # pull provider and event id info from query xml
    $provider = $xml.querylist.query.select.path
    $path = $xml.querylist.query.select.'#text'

    # need to account for:
    #   eventid= 123 or eventid=234
    #   eventid= 123-345
    #   eventid= 123,234
    $ids = [regex]::Matches($path, 'EventID=(.*)\)')

    # get events from all providers where provider matches
    $providerEvents = $allProviders | ? {($_.LogLinks.LogName -contains $provider)}

    $eventData = @() # to hold event data for output

    # for each event id in matches pulled from query xml
    $ids.groups[1..($ids.groups.count -1)] | % {
        $id = $_.value
        $e = $providerEvents.Events | ? Id -eq $id

        $eventData += $e | select id, {$_.level.displayname}, description
    }

    $eventData | Export-Csv $location\WEFDocs.csv
}

#   get event id's in scope
#   split on comma
#   if contains '-' split and create range
#   get provider events (get-winevent -listprovider "prov").events
#   get event id's which match subscription
#   create output object

# dump to csv or excel