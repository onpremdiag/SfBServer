################################################################################
# MIT License
#
# Copyright (c) Microsoft Corporation. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Filename: InsightActions.psd1
# Description: Localized Insight actions
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 3/1/2021 1:24 PM
#
# Last Modified On: 3/1/2021 1:44 PM
#################################################################################
ConvertFrom-StringData @'
###PSLOC
	IDAccountMissingSfbServerAdminRights             = Please make sure account is member of RTCUniversalServerAdmins or CsAdministrator domain group.
	IDAutoDiscoverDoesNotExist                       = Please review Exchange IIS service certificate or consider using wildcard certificate. For more details, please refer to the following article https://docs.microsoft.com/exchange/architecture/client-access/assign-certificates-to-services?view=exchserver-2019
	IDAutoDiscoverNameDoNotMatch                     = Please confirm that '{0}' CNAME record points to a DNS record within same domain complying with strict name matching. For more details, please refer to the following article: https://docs.microsoft.com/exchange/architecture/client-access/autodiscover?view=exchserver-2019.
	IDBadAutoDiscoverServiceInternalUri              = Please verify and correct AutoDiscoverServiceInternalUri configuration using Set-ClientAccessServer cmdlet.
	IDCertificateSubjectMissing                      = Please confirm if Microsoft 365 Certificate Revocation Lists URLs https://crl.microsoft.com and https://mscrl.microsoft.com are reachable.
	IDCheckLocalDBVersionMismatch                    = Please install the latest Skype for Business Server cumulative update available at https://docs.microsoft.com/skypeforbusiness/sfb-server-updates.
	IDCheckSQLVersion                                = Please verify connection to SQL server and refer to the following for guidance: https://support.microsoft.com/topic/kb3135244-tls-1-2-support-for-microsoft-sql-server-e4472ef8-90a9-13c1-e4d8-44aad198cdbe
	IDClientOAuthDisabled                            = Please run this command in the Skype for Business Management Shell: Set-CsOAuthConfiguration -ClientAuthorizationOAuthServerIdentity evoSTS.
	IDCMSReplicationNotSuccessful                    = The last successful replication for this server is: {0}. If the replication date is more than an hour old, then you will need to determine why replication is failing to the edge server. For more information please refer to the following article https://docs.microsoft.com/skypeforbusiness/troubleshoot/server-configuration/central-management-store-replication-failures.
	IDCommandNotFoundException                       = Please contact your system administrator or open a support ticket with Microsoft.
	IDContactSupport                                 = Please contact your system administrator or open a support ticket with Microsoft.
	IDDNSARecord                                     = Please refer to https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/decommission-manage-dns-entries for guidance
	IDDNSCNAMERecord                                 = Please refer to https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/decommission-manage-dns-entries for guidance
	IDDNSNameDoesNotExist                            = Please verify that the domain record '{0}' exists and is correct and attempt this operation again.
	IDDNSOnPremises                                  = Please refer to https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/decommission-manage-dns-entries for guidance
	IDDNSSRVRecord                                   = Please refer to https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/decommission-manage-dns-entries for guidance
	IDDNSTXTRecord                                   = Please refer to https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/decommission-manage-dns-entries for guidance
	IDDNSTypeOther                                   = Please refer to https://docs.microsoft.com/en-us/skypeforbusiness/hybrid/decommission-manage-dns-entries for guidance
	IDDomainNotApprovedForFederation                 = Please add '{0}' domain to allowed domain list. For more information please refer to the following article https://docs.microsoft.com/powershell/module/skype/new-csalloweddomain?view=skype-ps or enable open federation by running 'Set-CsAccessEdgeConfiguration -UseDnsSrvRouting -EnablePartnerDiscovery $true' PowerShell command.
	IDDoNotAllowAllFederatedPartners                 = Please configure On-Premise Allowed domains list to match with O365 Tenant Allowed domains list configuration. For more information please refer to the following article https://docs.microsoft.com/skypeforbusiness/hybrid/plan-hybrid-connectivity.
	IDDoNotAllowAllFederatedUsers                    = Please enable federated user access in your O365 Tenant. For more information, please refer to the following article https://docs.microsoft.com/powershell/module/skype/set-cstenantfederationconfiguration.
	IDDoNotAllowSharedSipAddressSpace                = Please enable Office 365 Tenant shared SIP address space. For more information please refer to the following article https://docs.microsoft.com/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.
	IDDuplicatesInTrustedRootCA                      = Please remove duplicate entries from {0}
	IDEdgeCertsNotOnSan                              = Please make sure that external edge certificate subject alternative name list contains all FQDNs of all SIP enabled domains and the same certificate is being used on each Edge Server in the Edge pool. For more information please refer to https://docs.microsoft.com/skypeforbusiness/plan-your-deployment/edge-server-deployments/edge-environmental-requirements#CertPlan and https://docs.microsoft.com/skypeforbusiness/hybrid/cloud-consolidation-edge-certificates.
	IDEdgeConfigDoNotAllowDnsSrvRouting              = Please enable discovery of federation partners by following guidance available at https://docs.microsoft.com/skypeforbusiness/manage/federation-and-external-access/access-edge/enable-or-disable-discovery-of-federation-partners.
	IDEdgeConfigDoNotAllowFederatedUsers             = Please enable users to communicate with users from federated domains by running the following cmdlet: Set-CsAccessEdgeConfiguration -AllowFederatedUsers $true.
	IDEdgeConfigDoNotAllowOutsideUsers               = Please enable remote user access. For more information please refer to the following article https://docs.microsoft.com/skypeforbusiness/manage/federation-and-external-access/access-edge/enable-or-disable-remote-user-access.
	IDEdgeServerNotListening                         = Remote PowerShell needs to be enabled on the edge server and confirm TCP port 5985 is not being blocked by the firewall. For more information please refer to the following article https://docs.microsoft.com/powershell/module/Microsoft.PowerShell.Core/Enable-PSRemoting?view=powershell-5.1.
	IDEdgeServerNotReachable                         = Please check if edge server is available and there are no connectivity issues. For more information please refer to the following article https://docs.microsoft.com/powershell/module/microsoft.powershell.management/test-connection?view=powershell-7.
	IDEdgeServerWrongExternalSipPort                 = Please confirm Edge Pool is enabled for listening on TCP port 5061.
	IDException                                      = Resolve the issue and run the Diagnostics script again.
	IDExchangeAutodiscoverUrlNotConfigured           = Please refer to the following for guidance: https://blog.schertz.name/2015/09/exchange-and-skype-for-business-integration/
	IDExternalDNSResolutionFailed                    = Please check if Skype for Business Edge Server public DNS server is configured and external DNS resolution is functional.
	IDExternalWSNotInSPNList                         = Please verify that Skype for Business Server external Web services URLs are registered as Service Principal names. For more details please refer to the following article https://docs.microsoft.com/skypeforbusiness/manage/authentication/configure-a-hybrid-environment
	IDFileDoesNotExist                               = Please contact your system administrator or open a support ticket with Microsoft.
	IDFileIsEmpty                                    = Please contact your system administrator or open a support ticket with Microsoft.
	IDFrontendFqdnCertNotOnSan                       = Please ensure that Skype for Business frontend certificate meets requirements described at https://docs.microsoft.com/skypeforbusiness/plan-your-deployment/requirements-for-your-environment/environmental-requirements#Certs.
	IDGetCsOnlineSipDomainFails                      = Please contact your system administrator or open a support ticket with Microsoft.
	IDGetCsServerVersionFailed                       = Please contact your system administrator or open a support ticket with Microsoft.
	IDGetCsServiceFails                              = Please verify that the edge server you are querying is reachable and that the 'AccessEdgeExternalSipPort' is set to 5061.
	IDGetCsTenantFails                               = Please verify that specified Microsoft 365 default domain has been setup. For more details please refer to the following guidance: https://docs.microsoft.com/microsoft-365/admin/setup/setup.
	IDHybridAuthFound                                = Please configure your On-Premise environment for hybrid modern authentication, as described in https://docs.microsoft.com/microsoft-365/enterprise/configure-skype-for-business-for-hybrid-modern-authentication.
	IDIncorrectFederatedDomainSrvRecord              = Please contact federated company system administrator to confirm their public SRV DNS record '_sipfederationtls.tcp.{0}' is resolvable and complies with strict name matching as described at https://docs.microsoft.com/skypeforbusiness/hybrid/plan-hybrid-connectivity#federation-requirements.
	IDIncorrectFederationRoute                       = Please configure federation route as described at https://docs.microsoft.com/skypeforbusiness/migration/configure-federation-routes-and-media-traffic.
	IDIncorrectLocalFederationDnsSrvRecord           = Please ensure that public federation DNS SRV record for your local SIP domain '_sipfederationtls.tcp.{0}' is resolvable and complies with strict name matching as described at https://docs.microsoft.com/skypeforbusiness/hybrid/plan-hybrid-connectivity#federation-requirements.
	IDIncorrectServerVersion                         = Please upgrade Skype for Business Server Web Components to match current Skype for Business Server edition. Please compare Get-CsServerPatchVersion and Get-CsServerVersion cmdlet output and confirm baseline version matches.
	IDInsufficientCores                              = Please refer to the appropriate documentation for your server installation.
	IDInsufficientCores2015                          = Please refer to the following guidance: https://docs.microsoft.com/skypeforbusiness/plan-your-deployment/requirements-for-your-environment/server-requirements
	IDInsufficientCores2019                          = Please refer to the following guidance: https://docs.microsoft.com/skypeforbusiness/plan/system-requirements
	IDInsufficientMemory                             = Please refer to the appropriate documentation for your server installation.
	IDInsufficientMemory2015                         = Please refer to the following guidance: https://docs.microsoft.com/skypeforbusiness/plan-your-deployment/requirements-for-your-environment/server-requirements
	IDInsufficientMemory2019                         = Please refer to the following guidance: https://docs.microsoft.com/skypeforbusiness/plan/system-requirements
	IDIPAddressNotInPool                             = In case DNS Load balancing is being Frontend IP address is required  to be added to the Pool DNS Record. Note: If hardware load balancing, this may be a false positive.
	IDIPv4DoesNotMatchReverseLookup                  = Please verify if the DNS record entry is correct as hosts files entries.
	IDIsNotSfbServerFrontend                         = The diagnostics script must be run on a Skype for Business Server Frontend.
	IDLegacyModernAuthDetected                       = Please configure your On-Premise environment for hybrid modern authentication, as described in https://docs.microsoft.com/microsoft-365/enterprise/configure-skype-for-business-for-hybrid-modern-authentication.
	IDListenAllNotFound                              = Please make sure that in the Topology Builder this server is configured to: Use all configured IP addresses.
	IDLocalCertStoreNotFound                         = Please verify if your account has permissions to execute 'Test-Path -Path "Cert:\\LocalMachine\\Root"' cmdlet.
	IDLocalSQLServerSchemaVersionMismatch            = Please install latest Skype for Business Server cumulative update.
	IDLogSpaceThreshold                              = Please trim the SQL transaction logs.
	IDLyncServerFound                                = Please open Skype for Business Server Topology Builder and confirm topology can be successfully loaded.
	IDMissingOAuthCertificate                        = Please open Skype for Business Server Deployment Wizard, select Install or Update Skype for Business Server System and run Step 3 to validate OAuth certificate. For more details please refer to the following article https://docs.microsoft.com/skypeforbusiness/manage/authentication/assign-a-server-to-server-certificate.
	IDModernAuthNotEnabled                           = Please create the EvoSTS Authentication Server Object, as described in https://docs.microsoft.com/microsoft-365/enterprise/configure-skype-for-business-for-hybrid-modern-authentication.
	IDModernAuthSfboNotEnabled                       = Please enable modern authentication for Skype for Business online. For more details please refer to the following guidance https://social.technet.microsoft.com/wiki/contents/articles/34339.skype-for-business-online-enable-your-tenant-for-modern-authentication.aspx.
	IDMultiHomePossible                              = Dual or multi-homed configurations are not supported for Front End Servers, Back End Servers, and Standard Edition servers. Please refer to the following article https://docs.microsoft.com/skypeforbusiness/plan/system-requirements.
	IDNameResolutionFails                            = Cannot resolve the DNS record for the Registrar FQDN.
	IDNoCertificatesFound                            = Please verify if your account has permissions to execute Get-ChildItem -Path "Cert:\\LocalMachine\\Root" cmdlet.
	IDNoClientAccessServerRole                       = Please review the client access server role Exchange service using Get-ClientAccessServer cmdlet.
	IDNoDefaultSipDomainFound                        = Please confirm that 'Get-CsSipDomain | Where-Object {$_.IsDefault}' cmdlet returns a non-empty result.
	IDNoDNSRecordFound                               = Please add a Pool FQDN DNS Record. For DNS Load Balancing all Front Servers in this Pool should be added.
	IDNoEdgePoolsFound                               = Please open Skype for Business Server Topology Builder and confirm if an Edge pool has been configured.
	IDNoEdgeServersFound                             = Please confirm that at least one Edge Server Pool has been configured.
	IDNoExchangeConnectivity                         = Please refer to the following for guidance: https://blog.schertz.name/2015/09/exchange-and-skype-for-business-integration/
	IDNoIPAddressForHostName                         = Please verify that the following PowerShell command 'Resolve-DnsName -Name '{0}' -Type A' returns a valid IP address.
	IDNoLogSpace                                     = Please execute 'DBCC SQLPERF(logspace)' t-SQL command against database and confirm 'Log Space Used (%)' is less than 60%.
	IDNoMonitoringRole                               = Please verify that monitoring role is installed/active on the current machine and try again.
	IDNoOauthConfigurationFound                      = Please refer to the following guidance: https://docs.microsoft.com/skypeforbusiness/plan-your-deployment/integrate-with-exchange/integrate-with-exchange
	IDNoOAuthServer                                  = Please confirm PowerShell script available at https://docs.microsoft.com/skypeforbusiness/manage/authentication/configure-a-hybrid-environment has been properly executed.
	IDNoPartnerApplication                           = Please refer to the following guidance: https://docs.microsoft.com/skypeforbusiness/manage/authentication/configure-a-hybrid-environment
	IDNoPoolIPAddresses                              = Please verify if Frontend End Pool DNS records are configured. For more details please refer to the following article https://docs.microsoft.com/skypeforbusiness/plan-your-deployment/network-requirements/dns
	IDNoRegistrarServerFound                         = Please configure the next hop pool for the '{0}' Edge Pool.
	IDNoReplicationStatus                            = Please verify if Get-CsManagementStoreReplicationStatus cmdlet returns a non-empty output.
	IDNoServicePrincipalNames                        = Please verify that Skype for Business Server external Web services URls are registered as Service Principal names. For more details please refer to the following article https://docs.microsoft.com/skypeforbusiness/manage/authentication/configure-a-hybrid-environment
	IDNoSession                                      = Please verify that the username and/or password supplied are correct and retry
	IDNoSIPAddress                                   = Please verify that SIP user {0} is SIP enabled and have an associated mailbox.
	IDNoSIPProxyFqdnFound                            = Please configure the hosting provider with ProxyFqdn=sipfed.online.lync.com. Please refer to the following guidance: https://docs.microsoft.com/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online
	IDNoSQLServiceInstancesFound                     = Please run 'Skype for Business Server Deployment Wizard', select 'Install or Update Skype for Business Server System' and confirm steps 1 to 3 status is 'Complete'.
	IDNotAMemberOfSecurityGroup                      = Please make sure account is member of RTCUniversalServerAdmins or CsAdministrator domain group.
	IDNoTenantIDFound                                = Please confirm that prior to executing PowerShell script available at https://docs.microsoft.com/skypeforbusiness/manage/authentication/configure-a-hybrid-environment you have replaced 'Fabrikam.com' by your tenant default domain
	IDNotFEMachine                                   = Please ensure that you are on a FrontEnd server and run the test again.
	IDNotOAuthServers                                = Please review Skype for Business Hybrid modern authentication configuration steps. For more details please refer to the following article https://docs.microsoft.com/microsoft-365/enterprise/hybrid-modern-auth-overview
	IDNoValidCertificates                            = Please ensure that Skype for Business frontend certificate meets requirements described at https://docs.microsoft.com/skypeforbusiness/plan-your-deployment/requirements-for-your-environment/environmental-requirements#Certs.
	IDNullOrEmptyPoolFQDN                            = Please confirm that 'Get-CsComputer -Identity {0}' cmdlet returns a non-empty result.
	IDOAuthCertficateExpired                         = Please open Skype for Business Server Deployment Wizard, select Install or Update Skype for Business Server System and run Step 3 to validate OAuth certificate. For more details please refer to the following article https://docs.microsoft.com/skypeforbusiness/manage/authentication/assign-a-server-to-server-certificate.
	IDOAuthCertficateNoThumbprint                    = Please open Skype for Business Server Deployment Wizard, select Install or Update Skype for Business Server System and run Step 3 to validate OAuth certificate. For more details please refer to the following article https://docs.microsoft.com/skypeforbusiness/manage/authentication/assign-a-server-to-server-certificate.
	IDOnlineOnPremAllowedDomainDoNotMatch            = Please review Allowed domains list in the On-Premise deployment as that must exactly match the Allowed domains list for your online tenant. For more information please refer to the following article https://docs.microsoft.com/skypeforbusiness/hybrid/plan-hybrid-connectivity.
	IDOnPremiseUsersFound                            = Please refer to https://docs.microsoft.com/skypeforbusiness/hybrid/cloud-consolidation-managing-attributes#method-2---clear-skype-for-business-attributes-for-all-on-premises-users-in-active-directory
	IDPartnerApplicationDisabled                     = Please consider enabling partner application or just re-run PowerShell script available at https://docs.microsoft.com/skypeforbusiness/manage/authentication/configure-a-hybrid-environment
	IDPatchUpdateAvailable                           = Please update to {0} which can be found at {1}.
	IDPoolFqdnCertNotOnSan                           = Please ensure that Skype for Business frontend certificate meets requirements described at https://docs.microsoft.com/skypeforbusiness/plan-your-deployment/requirements-for-your-environment/environmental-requirements#Certs.
	IDPropertyNotFoundException                      = Please verify if PowerShell object returns all expected properties.
	IDProxyEnabled                                   = Please refer to https://docs.microsoft.com/microsoft-365/enterprise/hybrid-modern-auth-overview?view=o365-worldwide for instructions on how to check and correctly use a proxy server.
	IDProxyMismatch                                  = Please refer to the following for guidance: https://docs.microsoft.com/microsoft-365/enterprise/hybrid-modern-auth-overview?view=o365-worldwide#do-you-meet-modern-authentication-prerequisites
	IDProxyShouldBeEmpty                             = Please refer to https://docs.microsoft.com/skypeforbusiness/hybrid/cloud-consolidation-disabling-hybrid for instructions on how to complete migration to the cloud.
	IDRegistryKeyNotFound                            = Please contact your system administrator or open a support ticket with Microsoft.
	IDRGSUsageTrend                                  = Please refer to the following guidance: https://social.technet.microsoft.com/Forums/office/en-US/7e472c38-35ac-42cb-ad4a-a683eb0becac/response-group-usage-report-not-working?forum=lyncinterop
	IDRootCACertificatesMisplaced                    = Please move certificates that are incorrectly stored in Trusted Root Certification Authorities store to proper store. You can identify misplaced certificate by running the following PowerShell command: Get-Childitem cert:\\LocalMachine\\root -Recurse | Where-Object {$_.Issuer -ne $_.Subject} | Format-List *
	IDSchannelSessionTicketNotDisabled               = Please disable Schannel session ticket TLS optimization by as described on https://docs.microsoft.com/skypeforbusiness/troubleshoot/server-configuration/event-32402-61045-front-end.
	IDSchannelTrustModeNotSet                        = Please set Schannel client authentication trust mode to 'Exclusive CA Trust' as described on https://docs.microsoft.com/windows-server/security/tls/what-s-new-in-tls-ssl-schannel-ssp-overview.
	IDServicePrincipalDoesNotExist                   = Please verify that Skype for Business Server external Web services URLs are registered as Service Principal names. For more details please refer to the following article https://docs.microsoft.com/skypeforbusiness/manage/authentication/configure-a-hybrid-environment
	IDSFBLocalDBsAreInSingleUserMode                 = Please reinstall latest Skype for Business Server cumulative update and confirm deployment completes without any failure.
	IDSfBOnlinePShellNotInstalled                    = Please install the Skype for Business PowerShell module and try again.
	IDSfbServerCertificateIsExpired                  = Please assign or renew Skype for Business Server certificate as described at https://docs.microsoft.com/skypeforbusiness/deploy/install/install-skype-for-business-server.
	IDSfbServerNoQuorum                              = Please execute Start-CsPool -PoolFqdn "{0}" cmdlet. If the problem persists, please follow guidance available at https://docs.microsoft.com/skypeforbusiness/plan-your-deployment/high-availability-and-disaster-recovery/high-availability.
	IDSfbServerPowerShellModuleNotLoaded             = The diagnostic script must be run on a server where Skype for Business Server PowerShell module is installed.
	IDSipDomainNotFederated                          = Please add the specified user domain as a Microsoft 365 verified domain.
	IDSIPHostingProviderAutodiscoverURLInvalid       = Please set AutodiscoverUrl Office 365 hosting provider property value as per guidance available at https://docs.microsoft.com/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.
	IDSIPHostingProviderNotEnabled                   = Please enable hosting provider required for Office 365 federation by following guidance available at https://docs.microsoft.com/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.
	IDSIPHostingProviderNotFound                     = Please create hosting provider required for Office 365 federation by following guidance available at https://docs.microsoft.com/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.
	IDSIPHostingProviderSharedAddressSpaceEnabled    = For hybrid environments, please run 'Federation is not working (Hybrid deployment)' diagnostic. If this shouldn't be configured as hybrid deployment, please disable shared SIP address space.
	IDSIPHostingProviderSharedAddressSpaceNotEnabled = Please enable shared SIP address space with Office 365 by following guidance available on the following article https://docs.microsoft.com/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.
	IDSIPSharedAddressSpaceEnabled                   = Please disable shared SIP address space with Office 365 by following guidance available on the following article https://docs.microsoft.com/skypeforbusiness/hybrid/cloud-consolidation-disabling-hybrid#disable-shared-sip-address-space-in-microsoft-365-organization.
	IDSQLServerBackendConnectionIsDown               = Please make sure that SQL Server back end services are running and firewall SQL exceptions are in place. SQL Server back end connectivity can be tested by running Test-CsDatabase -ConfiguredDatabases - SqlSerfverFqdn <SQLBackendFqdn>.
	IDSQLServicesNotRunning                          = Please start SQL Server services by running Start-Service -DisplayName "SQL Server (*)" PowerShell command.
	IDSSLNotDisabled                                 = Please refer to the following guidance: https://docs.microsoft.com/skypeforbusiness/manage/topology/disable-tls-1.0-1.1
	IDStrongCryptoNotSet                             = Please refer to the following guidance: https://docs.microsoft.com/skypeforbusiness/manage/topology/disable-tls-1.0-1.1
	IDTeamsModuleNotLoaded                           = Please visit https://docs.microsoft.com/microsoftteams/teams-powershell-install for instructions on how to acquire and install
	IDTestCsDatabaseNoResults                        = The 'Test-CsDatabase -LocalService' returned an empty result. If problem persists please contact your system administrator or open a support ticket with Microsoft.
	IDTestNetworkConnectionFails                     = Please confirm DNS server is reachable. If problem persists please contact your system administrator or open a support ticket with Microsoft.
	IDTLSNotEnabled                                  = Please refer to the following guidance: https://docs.microsoft.com/skypeforbusiness/manage/topology/disable-tls-1.0-1.1
	IDTooManyCertsInRootCA                           = Local computer 'Trusted Root Certification Authorities' store should have less than {0} certificates. Please remove certificates incorrectly stored.
	IDUCSConnectivityNotAvailable                    = To address the problem please follow guidance available at https://docs.microsoft.com/skypeforbusiness/plan-your-deployment/integrate-with-exchange/integrate-with-exchange to configure Exchange integration. Alternatively consider disabling UCS since is no longer default contact list provider.
	IDUnableToConnect                                = Please verify that the destination server, '{0}', is reachable and that the user has permission to access the server remotely.
	IDUnableToConnectToAAD                           = Please verify you can connect to Azure AD using Connect-MsolService. For more details please refer to the following article https://docs.microsoft.com/microsoft-365/enterprise/connect-to-microsoft-365-powershell?view=o365-worldwide
	IDUnableToConnectToEdgeServer                    = Please run the following and attempt again: Set-Item wsman:\\localhost\\client\\TrustedHosts -Value {0} -Force
	IDUnableToGetOAuthConfiguration                  = Please review Skype for Business Hybrid modern authentication configuration steps. For more details please refer to the following article https://docs.microsoft.com/microsoft-365/enterprise/hybrid-modern-auth-overview
	IDUnableToGetProductName                         = Please verify if Get-CsServerVersion cmdlet returns a valid output.
	IDUnableToGetRemoteCertificate                   = Please verify if local server can communicate remotely with server {0} on port TCP 443
	IDUnableToGetServiceInfo                         = Please confirm that 'Get-CsComputer' and 'Get-CsService' cmdlet execution is successful.
	IDUnableToGetVersion                             = Please verify if Get-CsServerVersion cmdlet returns a valid output.
	IDUnableToImportExchangeCmdlets                  = Please verify if remote Exchange PowerShell control for server '{0}' is allowed. For more details please refer to the following article: https://docs.microsoft.com/powershell/exchange/control-remote-powershell-access-to-exchange-servers?view=exchange-ps
	IDUnableToImportRemoteSession                    = Please verify if remote Exchange PowerShell control for server '{0}' is allowed. For more details please refer to the following article: https://docs.microsoft.com/powershell/exchange/control-remote-powershell-access-to-exchange-servers?view=exchange-ps
	IDUnableToResolveDNSName                         = Please confirm that 'Resolve-DnsName' cmdlet successfully performs a DNS query for each Edge Server in the Edge pool and each Frontend in the Frontend pool.
	IDUnableToResolveServerFQDN                      = Please execute 'Resolve-DnsName -Name $env:COMPUTERNAME -Type A' cmdlet and confirm valid output is returned.
	IDUnableToRetrieveSSLSettings                    = Please confirm that the logged in account has the correct permissions to access the registry. If it does, please contact your system administrator or open a support ticket with Microsoft.
	IDUnableToRetrieveTLSSettings                    = Please confirm that the logged in account has the correct permissions to access the registry. If it does, please contact your system administrator or open a support ticket with Microsoft.
	IDUnknownDomain                                  = Please confirm if $env:USERDNSDOMAIN environment variable points to correct user local domain
	IDUnknownProduct                                 = '{0}' is not an expected value
	IDUpgradeSQLExpress                              = Please upgrade to {0}: {1}
	IDUserNotFound                                   = Please verify that the user exists and try again. If the issue persists, please contact your system administrator for additional guidance.
	IDUserNotUCSEnabled                              = No action required as this warning and can be safely ignored. Potential user contact list issues are not related to either UCS or Exchange as user contact list is still residing on SQL.
	IDUsersValidationErrorFound                      = Please refer to https://docs.microsoft.com/skypeforbusiness/hybrid/cloud-consolidation-managing-attributes#method-2---clear-skype-for-business-attributes-for-all-on-premises-users-in-active-directory
	IDUserUCSEnabledNotMigrated                      = Please check if the user has logged in Skype for Business at least once or alternatively consider disabling user for Unified Contact Store.
	IDWinHttpSecureProtocols                         = Please refer to the following guidance: https://docs.microsoft.com/skypeforbusiness/manage/topology/disable-tls-1.0-1.1
	IDWrongMetadataUrlConfiguration                  = Please refer to the following guidance: https://docs.microsoft.com/skypeforbusiness/deploy/integrate-with-exchange-server/configure-partner-applications
	IDWrongOnlineMetadataUrlConfiguration            = Please refer to the following guidance: https://docs.microsoft.com/skypeforbusiness/manage/authentication/configure-a-hybrid-environment
	IDWrongPartnerApplication                        = Please re-run PowerShell script available at https://docs.microsoft.com/skypeforbusiness/manage/authentication/configure-a-hybrid-environment
	IDWrongPowerPlan                                 = Please ensure that the power plan is set to 'High performance' only.
	IDWrongVerificationLevel                         = Please set VerificationLevel Office 365 hosting provider property value as per guidance available at https://docs.microsoft.com/skypeforbusiness/hybrid/configure-federation-with-skype-for-business-online.
	IDInsufficientSQLCores                           = Expected: {0}, Actual: {1}. Please refer to the following guidance: https://docs.microsoft.com/sql/sql-server/compute-capacity-limits-by-edition-of-sql-server?view=sql-server-ver15
	IDEvalLicenseFound                               = Please apply valid volume license key
	IDExpiringCertificates                           = Please renew certificates prior to expiration
	IDUnhealthyDisk                                  = Please review event logs for any disk errors
	IDSQLPerfIssues                                  = Please refer to the following guidance: https://docs.microsoft.com/sql/relational-databases/errors-events/mssqlserver-833-database-engine-error?view=sql-server-ver15
	IDSQLDriveFull                                   = Please refer to the following guidance: https://systemcenter.wiki/?GetElement=Microsoft.LS.2013.Monitoring.Rule.InfoEvent.Registrar.ES_E_DATABASE_DRIVE_FULL&Type=Rule&ManagementPack=Microsoft.LS.2013.Monitoring.ComponentAndUser&Version=5.0.8308.956
'@