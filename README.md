# PSWEF
PSWEF is a PowerShell module for querying and administering Windows Event Forwarding and Windows Event Collectors.

## Usage examples
### List all subscriptions managed by the specified Windows Event Collector Server.
```powershell
PS C:\> Get-WEFSubscription -Server Server01 -List

Subscription-One
Subscription-Two
Subscription-Three
```

### Return details for the specified subscription. Add param ```-Format XML``` to get the raw XML of the subscription.
```powershell
PS C:\> Get-WEFSubscription -Server Server01 -Subscription Example-Subscription

SubscriptionId                  : Example-Subscription
SubscriptionType                : SourceInitiated
Description                     : Custom event subscription
Enabled                         : true
ConfigurationMode               : Custom
Delivery                        : @{Mode=Push; Batching=; PushSettings=}
Query                           :

                                      <QueryList>
                                        <Query Id="0" Path="Security">
                                          <Select Path="Security">*[System[(EventID &gt;=4624 and EventID &lt;=4626)]]</Select>
                                        </Query>
                                      </QueryList>

ReadExistingEvents              : true
TransportName                   : http
ContentFormat                   : RenderedText
Locale                          : Locale
LogFile                         : Example-LogFile
AllowedSourceNonDomainComputers :
AllowedSourceDomainComputers    : O:NSG:NSD:(A;;GA;;;DC)(A;;GA;;;NS)(A;;GA;;;DD)
```