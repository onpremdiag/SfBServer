#IM and Presence problems between on-premised and online users
**Owner:** João Loureiro

#Description

This scenario checks if Skype for Business Server hybrid deployment is functional and properly configured. For more details please refer to the following article [Configure Skype for Business hybrid](https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online)

[[_TOC_]]

#Execution flow<br/>


Parameters <------ **Scenario**  -------> Analyzer --------> Rules

::: mermaid
graph LR

  SDPresenceIMNotWorking(SDPresenceIMNotWorking) --1--> ADEdgeServerAvailable[ADEdgeServerAvailable]
  SDPresenceIMNotWorking--2--> ADCheckSecurityGroupMembership[ADCheckSecurityGroupMembership]
  SDPresenceIMNotWorking--3--> ADIsSfbServerAdminAccount[ADIsSfbServerAdminAccount]
  SDPresenceIMNotWorking--4--> ADCheckSIPHostingProvider[ADCheckSIPHostingProvider]
  SDPresenceIMNotWorking--5--> ADCheckEdgeConfiguration[ADCheckEdgeConfiguration]
  SDPresenceIMNotWorking--6--> ADCheckEdgePoolConfiguration[ADCheckEdgePoolConfiguration]
  SDPresenceIMNotWorking--7--> ADCompareOnPremToOnline[ADCompareOnPremToOnline]
  SDPresenceIMNotWorking--8--> ADCertificateCheck[ADCertificateCheck]

  PDTenantUserID[\PDTenantUserID\] -.-> SDPresenceIMNotWorking
  PDTenantPassword[\PDTenantPassword\] -.-> SDPresenceIMNotWorking
  PDEdgeUserID[\PDEdgeUserID\] -.-> SDPresenceIMNotWorking
  PDEdgePassword[\PDEdgePassword\] -.-> SDPresenceIMNotWorking

  ADEdgeServerAvailable --1.1--> RDEdgeServerAvailable[RDEdgeServerAvailable]
  ADEdgeServerAvailable --1.2--> RDEdgeServerListening[RDEdgeServerListening]
  ADCheckSecurityGroupMembership --2.1--> RDCheckSfbServerAccountAdminRights[RDCheckSfbServerAccountAdminRights]
  ADIsSfbServerAdminAccount --3.1--> RDCheckSfbServerAccountAdminRights[RDCheckSfbServerAccountAdminRights]
  ADCheckSIPHostingProvider --4.1--> RDCheckProxyFQDN[RDCheckProxyFQDN]
  ADCheckSIPHostingProvider --4.2--> RDCheckVerificationLevel[RDCheckVerificationLevel]
  ADCheckSIPHostingProvider --4.3--> RDIsHostingProviderEnabled[RDIsHostingProviderEnabled]
  ADCheckSIPHostingProvider --4.4--> RDCheckSharedAddressSpace[RDCheckSharedAddressSpace]
  ADCheckSIPHostingProvider --4.5--> RDCheckAutoDiscoverURL[RDCheckAutoDiscoverURL]
  ADCheckEdgeConfiguration --5.1--> RDEdgeConfigAllowOutsideUsers[RDEdgeConfigAllowOutsideUsers]
  ADCheckEdgeConfiguration --5.2--> RDEdgeConfigAllowFederatedUsers[RDEdgeConfigAllowFederatedUsers]
  ADCheckEdgeConfiguration --5.3--> RDEdgeConfigUseDnsSrvRouting[RDEdgeConfigUseDnsSrvRouting]
  ADCheckEdgePoolConfiguration --6.1--> RDCheckCMSReplicationStatus[RDCheckCMSReplicationStatus]
  ADCheckEdgePoolConfiguration --6.2--> RDCheckEdgePoolCount[RDCheckEdgePoolCount]
  ADCompareOnPremToOnline --7.1--> RDCompareAllowedDomains[RDCompareAllowedDomains]
  ADCompareOnPremToOnline --7.2--> RDAllowFederatedPartners[RDAllowFederatedPartners]
  ADCompareOnPremToOnline --7.3--> RDAllowFederatedUsers[RDAllowFederatedUsers]
  ADCompareOnPremToOnline --7.4--> RDSharedSipAddressSpace[RDSharedSipAddressSpace]
  ADCertificateCheck--> |8.1| RDCheckEdgeCerts[RDCheckEdgeCerts]
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
### RDCheckSharedAddressSpace
Check if hosting provider  EnabledSharedAddressSpace is set to true
### RDCheckAutoDiscoverURL
Check if hosting provider AutodiscoverURL is properly set
$this.Success = $HostingProvider.AutodiscoverURL -match "^https://(webdir[\w]*)\..*$"
### RDEdgeConfigAllowOutsideUsers
Check if edge Get-CsAccessEdgeConfiguration -AllowOutsideUsers is set to true
### RDEdgeConfigAllowFederatedUsers
Check if edge Get-CsAccessEdgeConfiguration -AllowFederatedUsers is set to true
### RDEdgeConfigUseDnsSrvRouting
Check if edge Get-CsAccessEdgeConfiguration -RoutingMethod is set to UseDnsSrvRouting
### RDCheckCMSReplicationStatus
Check if CMS replication status is up-to-date for each edge server
$replicationStatus = (Get-CsManagementStoreReplicationStatus | Where-Object {$_.ReplicaFqdn -eq $EdgeServer}).UpToDate
$replicationDate   = (Get-CsManagementStoreReplicationStatus | Where-Object {$_.ReplicaFqdn -eq $EdgeServer}).LastStatusReport
### RDCheckEdgePoolCount
Check there is one (and no more than one) edge pool enabled for federation
Get-CsService -EdgeServer | Where-Object {$_.AccessEdgeExternalSipPort -eq 5061}
### RDCompareAllowedDomains
Compare on-prem and online allowed federated domains is identical
Get-CsTenantFederationConfiguration.AllowedDomains
(Get-CsAllowedDomain).Domain
### RDAllowFederatedPartners
Check if all federated domains are allowed (open federation)
Get-CsTenantFederationConfiguration.AllowedDomains -match "AllowAllKnownDomains"
Get-CsAccessEdgeConfiguration -EnablePartnerDiscovery
### RDAllowFederatedUsers
Check if O365 tenant allows federated users
Get-CsTenantFederationConfiguration -AllowFederatedUsers is true
### RDSharedSipAddressSpace
Check if tenant SharedSipAddressSpace property is set to true
Get-CsTenantFederationConfiguration -SharedSipAddressSpace
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

| Language | Key                    | Message                                                       |
| -------- | ---------------------- | ------------------------------------------------------------- |
| en-us    | SDPresenceIMNotWorking | IM and Presence problems between on-premised and online users |

###Parameters description, prompt and example<br/>

| Language | Key              | Description                                                                             | Prompt                                        | Example                                 |
| -------- | ---------------- | --------------------------------------------------------------------------------------- | --------------------------------------------- | --------------------------------------- |
| en-us    | PDTenantUserID   | The admin account for your O365 tenant                                                  | Office 365 tenant admin username              | user1@[domain_scrubbed].onmicrosoft.com |
| en-us    | PDTenantPassword | The password associated with your tenant admin account                                  | Office 365 tenant admin password              |                                         |
| en-us    | PDEdgeUserID     | The admin username for the Skype for Business Edge Skype for Business Edge server admin | Skype for Business Edge server admin username | user1@contoso.com \| user1              |
| en-us    | PDEdgePassword   | The password associated with your Skype for Business Edge server username               | Skype for Business Edge server admin password |                                         |

###Analyzer description<br/>

| Language | Key                            | Message                                                                                    |
| -------- | ------------------------------ | ------------------------------------------------------------------------------------------ |
| en-us    | ADEdgeServerAvailable          | Verifies that the Edge Server is available for remote powershell connections               |
| en-us    | ADCheckSecurityGroupMembership | Verifies if account has Skype for Business Server administrative privileges                |
| en-us    | ADIsSfbServerAdminAccount      | Verifies if account has Skype for Business Server administrative privileges                |
| en-us    | ADCheckSIPHostingProvider      | Verifies the SIP Hosting Provider settings for on-prem deployment                          |
| en-us    | ADCheckEdgeConfiguration       | Verifies the edge pool configuration for hybrid deployment                                 |
| en-us    | ADCheckEdgePoolConfiguration   | Verifies the edge pool configuration is correct                                            |
| en-us    | ADCompareOnPremToOnline        | Verifies the on-premise domains configuration match Office 365 tenant domain configuration |
| en-us    | ADCertificateCheck             | Verifies if Edge servers external certificate meet basic requirements                      |

###Rule description<br/>

| Language | Key                                | Message                                                                                         |
| -------- | ---------------------------------- | ----------------------------------------------------------------------------------------------- |
| en-us    | RDEdgeServerAvailable              | Determine if the edge server is reachable (ping)                                                |
| en-us    | RDEdgeServerListening              | Determine if the edge server is listening on port 5985                                          |
| en-us    | RDCheckSfbServerAccountAdminRights | Determine if current account has Skype for Business Server administrative privileges            |
| en-us    | RDCheckProxyFQDN                   | Determine if the Office 365 hosting provider ProxyFqdn is correct                               |
| en-us    | RDCheckVerificationLevel           | Determine if the SIP hosting provider messages verification level is set correctly              |
| en-us    | RDIsHostingProviderEnabled         | Determine if hosting provider required to communicate with Skype for Business Online is enabled |
| en-us    | RDCheckSharedAddressSpace          | Determine if the SkypeforBusinessOnline hosting provider SharedAddressSpace is enabled          |
| en-us    | RDCheckAutoDiscoverURL             | Determine if the SkypeforBusinessOnline hosting provider AutodiscoverURL is valid               |
| en-us    | RDEdgeConfigAllowOutsideUsers      | Determine if the edge configuration allows outside users                                        |
| en-us    | RDEdgeConfigAllowFederatedUsers    | Determine if remote user access is enabled                                                      |
| en-us    | RDEdgeConfigUseDnsSrvRouting       | Determine if the edge is configured for open federation                                         |
| en-us    | RDCheckCMSReplicationStatus        | Determine if Central Management Store replication is up to date                                 |
| en-us    | RDCheckEdgePoolCount               | Determine if just one edge pool is enabled for federation                                       |
| en-us    | RDCompareAllowedDomains            | Determine if the on-premise domains configuration match Office 365 tenant domain configuration  |
| en-us    | RDAllowFederatedPartners           | Determine if the Office 365 tenant Skype federation is enabled                                  |
| en-us    | RDAllowFederatedUsers              | Determine if the Office 365 tenant Skype federation is enabled                                  |
| en-us    | RDSharedSipAddressSpace            | Determine if the Office 365 tenant shared SIP address space is enabled                          |
| en-us    | RDCheckEdgeCerts                   | Determine if Edge servers external certificate meet basic requirements                          |

###Insight detection description<br/>

| Language | Key                                                                                  | Message                                                                                                                   |
| -------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| en-us    | IDEdgeServerNotListening                                                             | The edge server, '{0}', is not listening on the remote TCP port 5985.                                                     |
| en-us    | IDAccountMissingSfbServerAdminRights                                                 | The diagnostic script must be executed using an account having Skype for Business Server administrative privileges.       |
| en-us    | IDSIPHostingProviderNotFound                                                         | The hosting provider required for Office 365 Federation is missing.                                                       |
| en-us    | IDWrongVerificationLevel                                                             | Office 365 hosting provider VerificationLevel parameter value is incorrect.                                               |
| en-us    | IDSIPHostingProviderNotEnabled                                                       | The hosting provider required for Office 365 Federation is not enabled.                                                   |
| en-us    | IDSIPHostingProviderSharedAddressSpaceNotEnabled                                     | Shared SIP address space required for federation with Office 365 is disabled.                                             |
| en-us    | IDSIPHostingProviderAutodiscoverURLInvalid                                           | Office 365 hosting provider autodiscover parameter value is incorrect.                                                    |
| en-us    | IDEdgeConfigDoNotAllowOutsideUsers                                                   | Remote user access is disabled.                                                                                           |
| en-us    | IDEdgeConfigDoNotAllowFederatedUsers                                                 | Federated user access is disabled.                                                                                        |
| en-us    | IDEdgeConfigDoNotAllowDnsSrvRouting                                                  | EnablePartnerDiscovery is currently disabled.                                                                             |
| en-us    | IDCMSReplicationNotSuccessful                                                        | Central Management Stored replication for '{0}' failed.                                                                   |
| en-us    | IDIncorrectFederationRoute                                                           | Topology needs to have at least one and just one Federated Edge Server.                                                   |
| en-us    | IDOnlineOnPremAllowedDomainDoNotMatch                                                | The allowed federated domain configured in your On Premise environment, '{0}', and your O365 Tenant, '{1}', do not match. |
| en-us    | IDDoNotAllowAllFederatedPartners                                                     | Allow All Federated Partners setting does not match between On-Premise vs. Online                                         |
| en-us    | IDDoNotAllowAllFederatedUsersOffice 365 Tenant federated users property is disabled. |                                                                                                                           |
| en-us    | IDDoNotAllowSharedSipAddressSpace                                                    | Office 365 Tenant shared SIP address space is disabled.                                                                   |
| en-us    | IDEdgeCertsNotOnSan                                                                  | Unable to find FQDN '{1}' on the edge server '{0}' external certificate subject alternative name list.                    |

###Insight action description<br/>

| Language | Key                                              | Message                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| -------- | ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| en-us    | IDEdgeServerNotListening                         | Remote PowerShell needs to be enabled on the edge server and confirm TCP port 5985 is not being blocked by the firewall. For more information please refer to the following article https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Core/Enable-PSRemoting?view=powershell-5.1.                                                                                                                                                                                   |
| en-us    | IDAccountMissingSfbServerAdminRights             | Please make sure account is member of RTCUniversalServerAdmins or CsAdministrator domain group.                                                                                                                                                                                                                                                                                                                                                                                           |
| en-us    | IDSIPHostingProviderNotFound                     | Please create hosting provider required for Office 365 federation by following guidance available at https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.                                                                                                                                                                                                                                                                        |
| en-us    | IDWrongVerificationLevel                         | Please set VerificationLevel Office 365 hosting provider property value as per guidance available at https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.                                                                                                                                                                                                                                                                        |
| en-us    | IDSIPHostingProviderNotEnabled                   | Please enable hosting provider required for Office 365 federation by following guidance available at https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.                                                                                                                                                                                                                                                                        |
| en-us    | IDSIPHostingProviderSharedAddressSpaceNotEnabled | For hybrid environments, please run 'Federation is not working (Hybrid deployment)' diagnostic. If this shouldn't be configured as hybrid deployment, please disable shared SIP adresss space.                                                                                                                                                                                                                                                                                            |
| en-us    | IDSIPHostingProviderAutodiscoverURLInvalid       | Please set AutodiscoverUrl Office 365 hosting provider property value as per guidance available at https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.                                                                                                                                                                                                                                                                          |
| en-us    | IDEdgeConfigDoNotAllowOutsideUsers               | Please enable remote user access. For more information please refer to the following article https://docs.microsoft.com/en-us/skypeforbusiness/manage/federation-and-external-access/access-edge/enable-or-disable-remote-user-access.                                                                                                                                                                                                                                                    |
| en-us    | IDEdgeConfigDoNotAllowFederatedUsers             | Please enable users to communicate with users from federated domains by running the following cmdlet: Set-CsAccessEdgeConfiguration -AllowFederatedUsers $true.                                                                                                                                                                                                                                                                                                                           |
| en-us    | IDEdgeConfigDoNotAllowDnsSrvRouting              | Please enable discovery of federation partners by following guidance available at https://docs.microsoft.com/en-us/skypeforbusiness/manage/federation-and-external-access/access-edge/enable-or-disable-discovery-of-federation-partners.                                                                                                                                                                                                                                                 |
| en-us    | IDCMSReplicationNotSuccessful                    | The last successful replication for this server is: {0}. If the replication date is more than an hour old, then you will need to determine why replication is failing to the edge server. For more information please refer to the following article https://docs.microsoft.com/en-us/skypeforbusiness/troubleshoot/server-configuration/central-management-store-replication-failures.                                                                                                   |
| en-us    | IDIncorrectFederationRoute                       | Please configure federation route as described at https://docs.microsoft.com/en-us/skypeforbusiness/migration/configure-federation-routes-and-media-traffic.                                                                                                                                                                                                                                                                                                                              |
| en-us    | IDOnlineOnPremAllowedDomainDoNotMatch            | Please review Allowed domains list in the on-premises deployment as that must exactly match the Allowed domains list for your online tenant. For more information please refer to the following article https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/plan-hybrid-connectivity.                                                                                                                                                                                                |
| en-us    | IDDoNotAllowAllFederatedPartners                 | Please configure On-Premises Allowed domains list to match with O365 Tenant Allowed domains list configuration. For more information please refer to the following article https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/plan-hybrid-connectivity.                                                                                                                                                                                                                             |
| en-us    | IDDoNotAllowAllFederatedUsers                    | Please enable federated user access in your O365 Tenant. For more information, please refer to the following article https://docs.microsoft.com/en-us/powershell/module/skype/set-cstenantfederationconfiguration.                                                                                                                                                                                                                                                                        |
| en-us    | IDDoNotAllowSharedSipAddressSpace                | Please enable Office 365 Tenant shared SIP address space. For more information please refer to the following article https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.                                                                                                                                                                                                                                                        |
| en-us    | IDEdgeCertsNotOnSan                              | Please make sure that external edge certificate subject alternative name list contains all FQDNs of all SIP enabled domains and the same certificate is being used on each Edge Server in the Edge pool. For more information please refer to https://docs.microsoft.com/en-us/skypeforbusiness/plan-your-deployment/edge-server-deployments/edge-environmental-requirements#CertPlan and https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/cloud-consolidation-edge-certificates. |