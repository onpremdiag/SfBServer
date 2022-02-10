#Federation is not working (OnPrem deployment)
**Owner:** João Loureiro

#Description

This scenario checks if Skype for Business Server federation in scope of a pure On Premises deployment is functional and properly configured. For more details please refer to the following article [Managing federation and external access to Skype for Business Server](https://docs.microsoft.com/en-us/skypeforbusiness/manage/federation-and-external-access/managing-federation-and-external-access)

[[_TOC_]]

#Execution flow<br/>


Parameters <------ **Scenario**  -------> Analyzer --------> Rules

::: mermaid
graph LR

  SDOnPremFederation(SDOnPremFederation) --1--> ADEdgeServerAvailable[ADEdgeServerAvailable]
  SDOnPremFederation--2--> ADIsSfbServerAdminAccount[ADIsSfbServerAdminAccount]
  SDOnPremFederation--3--> ADCheckSIPHostingProviderForOnPrem[ADCheckSIPHostingProviderForOnPrem]
  SDOnPremFederation--4--> ADCheckEdgeOnPremConfiguration[ADCheckEdgeOnPremConfiguration]
  SDOnPremFederation--5--> ADCheckEdgePoolConfiguration[ADCheckEdgePoolConfiguration]
  SDOnPremFederation--6--> ADCheckFederatedDomain[ADCheckFederatedDomain]
  SDOnPremFederation--7--> ADCheckFederationDNSRecords[ADCheckFederationDNSRecords]
  SDOnPremFederation--8--> ADCertificateCheck[ADCertificateCheck]

  PDEdgeUserID[\PDEdgeUserID\] -.-> SDOnPremFederation
  PDEdgePassword[\PDEdgePassword\] -.-> SDOnPremFederation
  PDRemoteFqdnDomain[\PDRemoteFqdnDomain\] -.-> SDOnPremFederation

  ADEdgeServerAvailable --1.1--> RDEdgeServerAvailable[RDEdgeServerAvailable]
  ADEdgeServerAvailable --1.2--> RDEdgeServerListening[RDEdgeServerListening]
  ADIsSfbServerAdminAccount --2.1--> RDCheckSfbServerAccountAdminRights[RDCheckSfbServerAccountAdminRights]
  ADCheckSIPHostingProviderForOnPrem --3.1--> RDCheckProxyFQDN[RDCheckProxyFQDN]
  ADCheckSIPHostingProviderForOnPrem --3.1--> RDCheckVerificationLevel[RDCheckVerificationLevel]
  ADCheckSIPHostingProviderForOnPrem --3.1--> RDIsHostingProviderEnabled[RDIsHostingProviderEnabled]
  ADCheckSIPHostingProviderForOnPrem --3.1--> RDCheckSharedAddressSpaceNotEnabled[RDCheckSharedAddressSpaceNotEnabled]
  ADCheckEdgeOnPremConfiguration --4.1--> RDEdgeConfigAllowOutsideUsers[RDEdgeConfigAllowOutsideUsers]
  ADCheckEdgeOnPremConfiguration --4.2--> RDEdgeConfigAllowFederatedUsers[RDEdgeConfigAllowFederatedUsers]
  ADCheckEdgePoolConfiguration --5.1--> RDCheckCMSReplicationStatus[RDCheckCMSReplicationStatus]
  ADCheckEdgePoolConfiguration --5.2--> RDCheckEdgePoolCount[RDCheckEdgePoolCount]
  ADCheckFederatedDomain --6.1--> RDCheckDomainApprovedForFederation[RDCheckDomainApprovedForFederation]
  ADCheckFederationDNSRecords --7.1--> RDCheckEdgeExternalDNS[RDCheckEdgeExternalDNS]
  ADCheckFederationDNSRecords --7.2--> RDCheckLocalDomainFederationDNSRecord[RDCheckLocalDomainFederationDNSRecord]
  ADCheckFederationDNSRecords --7.2--> RDCheckFederatedDomainDNSRecords[RDCheckFederatedDomainDNSRecords]
  ADCertificateCheck --8.1--> RDCheckEdgeCerts[RDCheckEdgeCerts]
:::

#Rules specifications<br/>
### RDEdgeServerAvailable
Check if each edge server is available
$available = Test-Connection -Server $edgeServer -Quiet
### RDEdgeServerListening
Check if each edge server can be reached
Test-TcpConnect -Server $edgeServer -Port $global:WinRMHTTPPort
### RDCheckSfbServerAccountAdminRights
Check if current account is member of RTCUniversalServerAdmins group
### RDCheckProxyFQDN
Check hosting provider
Get-CsHostingProvider | Where-Object {$_.ProxyFqdn -eq sipfed.online.lync.com }
### RDCheckVerificationLevel
Check if hosting provider verification level is set to UseSourceVerification
$HostingProvider.VerificationLevel -eq 'UseSourceVerification'
### RDIsHostingProviderEnabled
Check if hosting provider reference above is enabled
$HostingProvider.Enabled
### RDCheckSharedAddressSpaceNotEnabled
Check if hosting provider  EnabledSharedAddressSpace is set to false
### RDEdgeConfigAllowOutsideUsers
Check if edge Get-CsAccessEdgeConfiguration -AllowOutsideUsers is set to true
### RDEdgeConfigAllowFederatedUsers
Check if edge Get-CsAccessEdgeConfiguration -AllowFederatedUsers is set to true
### RDCheckCMSReplicationStatus
Check if CMS replication status is up-to-date for each edge server
$replicationStatus = (Get-CsManagementStoreReplicationStatus | Where-Object {$_.ReplicaFqdn -eq $EdgeServer}).UpToDate
$replicationDate   = (Get-CsManagementStoreReplicationStatus | Where-Object {$_.ReplicaFqdn -eq $EdgeServer}).LastStatusReport
### RDCheckEdgePoolCount
Check there is one (and no more than one) edge pool enabled for federation
Get-CsService -EdgeServer | Where-Object {$_.AccessEdgeExternalSipPort -eq 5061}
### RDCheckDomainApprovedForFederation
Check if remote domain provided as input parameter was approved for federation (closed federation scenario)
Get-CsAllowedDomain | Where-Object {$_.Domain -eq $RemoteDomainFqdn }
### RDCheckEdgeExternalDNS
Check edge external DNS resolution is working fine
Resolve-DnsName -Name sipfed.online.lync.com -Type A -DnsOnly | Where-Object {$_.Section -eq 'Answer'}
### RDCheckLocalDomainFederationDNSRecord
Check if local domain federation SRV record can be resolved
Resolve-DnsName -Name $global:SIPFederationTLS -Type SRV -DnsOnly | Where-Object {$_.Type -eq 'SRV'}
### RDCheckFederatedDomainDNSRecords
Check if remote domain federation SRV record can be resolved
Resolve-DnsName -Name $remote_domain -Type SRV -DnsOnly | Where-Object {$_.Type -eq 'SRV'}
### RDCheckEdgeCerts
Check if edge certificate SAN entries include all local SIP enabled domains
$FQDN      = (Get-CsService -EdgeServer -PoolFqdn $PoolFQDN).AccessEdgeExternalFqdn
$SANOnCert = Test-SanOnCert -SAN $FQDN -Certificate $edgeCert

#Messages

When particular rule detects an issue (return value is  false) an **Insight detection** and **Insight Action** is displayed in addition to **Analyzer message** and **Rule description**. For more details see example below:

(...)
<span style="color:green">[+] Verifies if target domain is approved for federation **-> Analyzer message**
&nbsp;&nbsp;&nbsp;&nbsp;[+] Determine if open federation is enabled or target domain is approved for federation **-> Rule message**</span>
<span style="color:red">[-] Verifies the on-premise domains configuration match Office 365 tenant domain configuration **-> Analyzer message**
&nbsp;&nbsp;&nbsp;&nbsp;[-] Determine if the on-premise domains configuration match Office 365 tenant domain configuration **-> Rule message**
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[-] Detection : The allowed federated domain configured in your On Premise environment, '[Domain not found]', and your O365 Tenant, 'domainnotinonprem.com', do not match. **-> Insight detection message**
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[-] Action : Please review Allowed domains list in the on-premises deployment as that must exactly match the Allowed domains list for your online tenant. For more information please refer to the following article https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/plan-hybrid-connectivity. **-->Insight action message**</span>
(...)

###Scenario description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | SDOnPremFederation| Federation is not working (OnPrem deployment) |

###Parameters description, prompt and example<br/>

| Language | Key                        | Description                        | Prompt | Example|
|----------|----------------------------|------------------------------------|--------|--------|
| en-us    | PDEdgeUserID| The admin username for the Skype for Business Edge Skype for Business Edge server admin | Skype for Business Edge server admin username |user1@contoso.com \| user1 |
| en-us    | PDEdgePassword| The password associated with your Skype for Business Edge server username |Skype for Business Edge server admin password||
| en-us    | PDRemoteFqdnDomain| Fully qualified domain name (FQDN) of the federated domain |Remote federated domain (FQDN)|domain.contoso.com \| contoso.com|

###Analyzer description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | ADEdgeServerAvailable| Verifies that the Edge Server is available for remote powershell connections |
| en-us    | ADIsSfbServerAdminAccount| Verifies if account has Skype for Business Server administrative privileges |
| en-us    | ADCheckSIPHostingProviderForOnPrem| Verifies the SIP Hosting Provider settings for on-prem deployment |
| en-us    | ADCheckEdgeOnPremConfiguration| Verifies the edge pool configuration for on-prem deployment |
| en-us    | ADCheckEdgePoolConfiguration| Verifies the edge pool configuration is correct |
| en-us    | ADCheckFederatedDomain| Verifies if target domain is approved for federation |
| en-us    | ADCheckFederationDNSRecords| Verifies the federation DNS records requirements |
| en-us    | ADCertificateCheck| Verifies if Edge servers external certificate meet basic requirements |

###Rule description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | RDEdgeServerAvailable| Determine if the edge server is reachable (ping) |
| en-us    | RDEdgeServerListening| Determine if the edge server is listening on port 5985 |
| en-us    | RDCheckSfbServerAccountAdminRights| Determine if current account has Skype for Business Server administrative privileges |
| en-us    | RDCheckProxyFQDN| Determine if the Office 365 hosting provider ProxyFqdn is correct |
| en-us    | RDCheckVerificationLevel| Determine if the SIP hosting provider messages verification level is set correctly |
| en-us    | RDIsHostingProviderEnabled| Determine if hosting provider required to communicate with Skype for Business Online is enabled |
| en-us    | RDCheckSharedAddressSpaceNotEnabled| For hybrid environments, please run 'Federation is not working (Hybrid deployment)' diagnostic. If this shouldn't be configured as hybrid deployment, please disable shared SIP adresss space. |
| en-us    | RDEdgeConfigAllowOutsideUsers| Determine if the edge configuration allows outside users |
| en-us    | RDEdgeConfigAllowFederatedUsers| Determine if remote user access is enabled |
| en-us    | RDCheckCMSReplicationStatus| Determine if Central Management Store replication is up to date |
| en-us    | RDCheckEdgePoolCount| Determine if just one edge pool is enabled for federation |
| en-us    | RDCheckDomainApprovedForFederation| Determine if open federation is enabled or target domain is approved for federation |
| en-us    | RDCheckEdgeExternalDNS| Determine if edge server allows external DNS resolution |
| en-us    | RDCheckLocalDomainFederationDNSRecord| Determine if local domain federation DNS SRV record is discoverable |
| en-us    | RDCheckFederatedDomainDNSRecords| Determine if federated domain DNS SRV is discoverable |
| en-us    | RDCheckEdgeCerts| Determine if Edge servers external certificate meet basic requirements |

###Insight detection description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | IDEdgeServerNotListening|The edge server, '{0}', is not listening on the remote TCP port 5985.|
| en-us    | IDAccountMissingSfbServerAdminRights|The diagnostic script must be executed using an account having Skype for Business Server administrative privileges.|
| en-us    | IDSIPHostingProviderNotFound|The hosting provider required for Office 365 Federation is missing.|
| en-us    | IDWrongVerificationLevel|Office 365 hosting provider VerificationLevel parameter value is incorrect.|
| en-us    | IDSIPHostingProviderNotEnabled|The hosting provider required for Office 365 Federation is not enabled.|
| en-us    | IDSIPHostingProviderSharedAddressSpaceEnabled| Shared SIP address space is enabled so this is configured as an hybrid environment. |
| en-us    | IDEdgeConfigDoNotAllowOutsideUsers|Remote user access is disabled.|
| en-us    | IDEdgeConfigDoNotAllowFederatedUsers|Federated user access is disabled.|
| en-us    | IDCMSReplicationNotSuccessful|Central Management Stored replication for '{0}' failed.|
| en-us    | IDIncorrectFederationRoute|Topology needs to have at least one and just one Federated Edge Server.|
| en-us    | IDDomainNotApprovedForFederation|Domain '{0}' is not approved for federation neither open federation is enabled.|
| en-us    | IDExternalDNSResolutionFailed|Attempting to resolve sipfed.online.lync.com DNS A record failed.|
| en-us    | IDIncorrectLocalFederationDnsSrvRecord|Federation SRV record for local SIP domain does not exist or is incorrect.|
| en-us    | IDIncorrectFederatedDomainSrvRecord|Remote federation SRV record does not exist or is incorrect.|
| en-us    | IDEdgeCertsNotOnSan|Unable to find FQDN '{1}' on the edge server '{0}' external certificate subject alternative name list.|

###Insight action description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | IDEdgeServerNotListening|Remote PowerShell needs to be enabled on the edge server and confirm TCP port 5985 is not being blocked by the firewall. For more information please refer to the following article https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Core/Enable-PSRemoting?view=powershell-5.1.|
| en-us    | IDAccountMissingSfbServerAdminRights|Please make sure account is member of RTCUniversalServerAdmins or CsAdministrator domain group.|
| en-us    | IDSIPHostingProviderNotFound|Please create hosting provider required for Office 365 federation by following guidance available at https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.|
| en-us    | IDWrongVerificationLevel|Please set VerificationLevel Office 365 hosting provider property value as per guidance available at https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.|
| en-us    | IDSIPHostingProviderNotEnabled|Please enable hosting provider required for Office 365 federation by following guidance available at https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.|
| en-us    | IDSIPHostingProviderSharedAddressSpaceEnabled|For hybrid environments, please run 'Federation is not working (Hybrid deployment)' diagnostic. If this shouldn't be configured as hybrid deployment, please disable shared SIP adresss space.|
| en-us    | IDEdgeConfigDoNotAllowOutsideUsers|Please enable remote user access. For more information please refer to the following article https://docs.microsoft.com/en-us/skypeforbusiness/manage/federation-and-external-access/access-edge/enable-or-disable-remote-user-access.|
| en-us    | IDEdgeConfigDoNotAllowFederatedUsers|Please enable users to communicate with users from federated domains by running the following cmdlet: Set-CsAccessEdgeConfiguration -AllowFederatedUsers $true.|
| en-us    | IDCMSReplicationNotSuccessful|The last successful replication for this server is: {0}. If the replication date is more than an hour old, then you will need to determine why replication is failing to the edge server. For more information please refer to the following article https://docs.microsoft.com/en-us/skypeforbusiness/troubleshoot/server-configuration/central-management-store-replication-failures.|
| en-us    | IDIncorrectFederationRoute|Please configure federation route as described at https://docs.microsoft.com/en-us/skypeforbusiness/migration/configure-federation-routes-and-media-traffic.|
| en-us    | IDDomainNotApprovedForFederation|Please add '{0}' domain to allowed domain list. For more information please refer to the following article https://docs.microsoft.com/en-us/powershell/module/skype/new-csalloweddomain?view=skype-ps or enable open federation by running 'Set-CsAccessEdgeConfiguration -UseDnsSrvRouting -EnablePartnerDiscovery $true' powershell command.|
| en-us    | IDExternalDNSResolutionFailed|Please check if Skype for Business Edge Server public DNS server is configured and external DNS resolution is functional.|
| en-us    | IDIncorrectLocalFederationDnsSrvRecord|Please ensure that public federation DNS SRV record for your local SIP domain '_sipfederationtls.tcp.{0}' is resolvable and complies with strict name matching as described at https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/plan-hybrid-connectivity#federation-requirements.|
| en-us    | IDIncorrectFederatedDomainSrvRecord|Please contact federated company system administrator to confirm their public SRV DNS record '_sipfederationtls.tcp.{0}' is resolvable and complies with strict name matching as described at https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/plan-hybrid-connectivity#federation-requirements.|
| en-us    | IDEdgeCertsNotOnSan|Please make sure that external edge certificate subject alternative name list contains all FQDNs of all SIP enabled domains and the same certificate is being used on each Edge Server in the Edge pool. For more information please refer to https://docs.microsoft.com/en-us/skypeforbusiness/plan-your-deployment/edge-server-deployments/edge-environmental-requirements#CertPlan and https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/cloud-consolidation-edge-certificates.|