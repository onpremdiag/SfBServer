# (Work in progress) Exchange Integration Not Working
Owner: Tiago Roxo

#Description
Check the integration between Skype for Business On-Premises and Exchange Hybrid (on-premises & Online)
For more details please refer to the following articles:
http://blog.schertz.name/2015/09/exchange-and-skype-for-business-integration/
https://docs.microsoft.com/pt-pt/skypeforbusiness/manage/authentication/configure-a-hybrid-environment?redirectedfrom=MSDN
https://techcommunity.microsoft.com/t5/skype-for-business-blog/online-meeting-icon-missing-from-owa-in-exchange-online/ba-p/621112
https://docs.microsoft.com/en-us/skypeforbusiness/plan-your-deployment/integrate-with-exchange/integrate-with-exchange
<br/>

[[_TOC_]]

#Execution flow

Parameters <------ **Scenario**  -------> Analyzer --------> Rules
::: mermaid
graph LR

P1[\PDSipAddress\] -.-> SDExchangeOnPremiseIntegrationNotWorking
P2[\PDExchangeServer\] -.-> SDExchangeOnPremiseIntegrationNotWorking
P3[\PDExchangeUserID\] -.-> SDExchangeOnPremiseIntegrationNotWorking
P4[\PDExchangePassword\] -.-> SDExchangeOnPremiseIntegrationNotWorking

P1[\PDSipAddress\] -.-> SDExchangeHybridIntegrationNotWorking
P2[\PDExchangeServer\] -.-> SDExchangeHybridIntegrationNotWorking
P3[\PDExchangeUserID\] -.-> SDExchangeHybridIntegrationNotWorking
P4[\PDExchangePassword\] -.-> SDExchangeHybridIntegrationNotWorking

P1[\PDSipAddress\] -.-> SDExchangeOnlineIntegrationNotWorking


SDExchangeOnPremiseIntegrationNotWorking(SDExchangeOnPremiseIntegrationNotWorking)--1--> ADExchangeOnPremise[ADExchangeOnPremise]
SDExchangeOnlineIntegrationNotWorking(SDExchangeOnlineIntegrationNotWorking)--2--> ADExchangeOnline[ADExchangeOnline]
SDExchangeHybridIntegrationNotWorking(SDExchangeHybridIntegrationNotWorking)--3--> ADExchangeHybrid[ADExchangeHybrid]

:::

<br/>

#Rules specifications
### RDAutoDiscoverServiceInternalUri
Determine if the AutoDiscoverServiceInternalUri value contains a valid configuration.

### RDCsPartnerApplication
Determine if the partner application exists and is configured with the proper value.

### RDExchangeAutodiscoverUrl
Determine if the OAuth ExchangeAutodiscoverUrl is well configured.

### RDOAuthCertificateValid
Determine if the OAuthTokenIssuer certificate has not expired and has a serial number.

### RDTestAppPrincipalExists
Determine if the app principal ID exists.

### RDTestAutoDiscover
Determine if the DNS name for the Autodiscover is resolvable.

### RDTestExchangeCertificateForAutodiscover
Determine if the Exchange On-Premises certificate SAN is configured for autodiscovery or wildcard.

### RDTestExchangeConnectivity
 Verifies that the Skype for Business Server Storage Service is working on a Front End Server.

### RDTestOAuthServerConfiguration
Determine if the OAuthServer configuration is correct.

### RDTestPartnerApplication
Determine if the Exchange application service exists and has the correct values.

<br/>

#Messages
When particular rule detects an issue (return value is  false) an **Insight detection** and **Insight Action** is displayed in addition to **Analyzer message** and **Rule description**. For more details see example below:

<br/>

###Scenario description
| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    |SDExchangeOnPremiseIntegrationNotWorking| Checks the integration between Skype for Business Server and Exchange (OnPrem deployment)
| en-us    |SDExchangeOnlineIntegrationNotWorking| Checks the integration between Skype for Business Server and Exchange (Online)
| en-us    |SDExchangeHybridIntegrationNotWorking| Checks the integration between Skype for Business Server and Exchange (Hybrid deployment)

<br/>

###Parameters description, prompt and example
| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    |

<br/>

###Rule description<br/>
| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    |

<br/>

###Insight Detection description
| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    |IDInvalidOAuthConfiguration| Determine if OAuthServer Metadata URL is correct or not.
| en-us    |IDPartnerApplicationDisabled| Determine if the Exchange Partner Application is enabled or disabled.
| en-us    |IDWrongPartnerApplication| Determine if the Exchange Partner Application Identifier it's wronng (00000002-0000-0ff1-ce00-000000000000)



<br/>

###Insight Action description
| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    |IDAutoDiscoverNameDoNotMatch|	**TODO**
| en-us    |IDBadAutoDiscoverServiceInternalUri|	**TODO**
| en-us    |IDExternalWSNotInSPNList|	**TODO**
| en-us    |IDInvalidOAuthConfiguration|	**TODO**
| en-us    |IDNameResolutionFails|	**TODO**
| en-us    |IDNoClientAccessServerRole|	**TODO**
| en-us    |IDNoDNSRecordFound|	**TODO**
| en-us    |IDNoEdgePoolsFound|	**TODO**
| en-us    |IDNoExchangeConnectivity|	**TODO**
| en-us    |IDNoIPAddressForHostName|	**TODO**
| en-us    |IDNoOAuthServer|	**TODO**
| en-us    |IDNoRegistrarServerFound|	**TODO**
| en-us    |IDNoServicePrincipalNames|	**TODO**
| en-us    |IDNoSIPAddress|	**TODO**
| en-us    |IDNoTenantIDFound|	**TODO**
| en-us    |IDPartnerApplicationDisabled|	**TODO**
| en-us    |IDServicePrincipalDoesNotExist|	**TODO**
| en-us    |IDUnableToConnectToAAD|	**TODO**
| en-us    |IDUnableToGetRemoteCertificate|	**TODO**
| en-us    |IDUnknownDomain|	**TODO**
| en-us    |IDWrongPartnerApplication|	Exchange Partner Application Identifier it's not equal to "00000002-0000-0ff1-ce00-000000000000)". Please review the following document - https://docs.microsoft.com/en-us/skypeforbusiness/manage/authentication/configure-a-hybrid-environment
| en-us    |IDIPv4DoesNotMatchReverseLookup|	**TODO**
| en-us    |IDAutoDiscoverDoesNotExist|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDCommandNotFoundException|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDContactSupport|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDEdgeServerWrongExternalSipPort|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDLocalCertStoreNotFound|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDMissingOAuthCertificate|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDNoCertificatesFound|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDNoDefaultSipDomainFound|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDNoEdgeServersFound|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDNoOauthConfigurationFound|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDNoPartnerApplication|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDNoReplicationStatus|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDNoServerFQDN|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDNoSIPProxyFqdnFound|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDNoSQLServiceInstancesFound|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDNoUserDatabase|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDNullOrEmptyPoolFQDN|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDOAuthCertficateExpired|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDOAuthCertficateNoThumbprint|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDPropertyNotFoundException|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDTestCsDatabaseNoResults|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDTestNetworkConnectionFails|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDUnableToGetServiceInfo|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDUnableToImportExchangeCmdlets|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDUnableToImportRemoteSession|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDUnableToResolveDNSName|	Please contact your system administrator or open a support ticket with Microsoft.
| en-us    |IDUnableToResolveServerFQDN|	Please contact your system administrator or open a support ticket with Microsoft.
