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
# Filename: InsightDetections.psd1
# Description: Localized Insight detections
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 3/1/2021 1:35 PM
#
# Last Modified On: 3/1/2021 1:44 PM
#################################################################################
ConvertFrom-StringData @'
###PSLOC
	IDAccountMissingSfbServerAdminRights             = The diagnostic script must be executed using an account having Skype for Business Server administrative privileges.
	IDAutoDiscoverDoesNotExist                       = The Exchange On-Premise IIS service certificate SAN does not contain an entry for autodiscover service.
	IDAutoDiscoverNameDoNotMatch                     = Autodiscover DNS CNAME record '{0}' points to a DNS A record. '{1}' is not respecting domain strict name matching
	IDBadAutoDiscoverServiceInternalUri              = The wrong configuration was found for the AutoDiscoverServiceInternalUri. Expected '{0}' but found '{1}'
	IDCertificateSubjectMissing                      = Cannot verify Microsoft 365 Certificate Revocation Lists URLs.
	IDCheckLocalDBVersionMismatch                    = The Skype for Business Server local database: '{0}', installed version: '{1}', does not match expected version: '{2}'.
	IDCheckSQLVersion                                = Unable to determine if SQL version is correct for TLS 1.2.
	IDClientOAuthDisabled                            = Hybrid Modern Authentication is not enabled.
	IDCMSReplicationNotSuccessful                    = Central Management Stored replication for '{0}' failed.
	IDCommandNotFoundException                       = Unable to find command: '{0}'
	IDDNSARecord                                     = The DNS record for '{0}' is pointing to an A record - unable to determine results
	IDDNSCNAMERecord                                 = The DNS record for '{0} is pointing to a CNAME record
	IDDNSNameDoesNotExist                            = The DNS record '{0}' does not appear to exist
	IDDNSOnPremises                                  = The DNS record '{0}' value does not point to online environment. Expected '{1}' but found '{2}'
	IDDNSSRVRecord                                   = The DNS SRV record for '{0}' is pointing to an online environment, '{1}'
	IDDNSTXTRecord                                   = The DNS record for '{0} is pointing to a TXT record
	IDDNSTypeOther                                   = The DNS record for '{0} is pointing to an unexpected type: {1} record
	IDDomainNotApprovedForFederation                 = Domain '{0}' is not approved for federation neither open federation is enabled.
	IDDoNotAllowAllFederatedPartners                 = Allow All Federated Partners setting does not match between On-Premise vs. Online
	IDDoNotAllowAllFederatedUsers                    = Office 365 Tenant federated users property is disabled.
	IDDoNotAllowSharedSipAddressSpace                = Office 365 Tenant shared SIP address space is disabled.
	IDDuplicatesInTrustedRootCA                      = The following duplicate(s) were found: FriendlyName: '{0}', Issuer: '{1}', Subject: '{2}', Thumbprint: {3}
	IDEdgeCertsNotOnSan                              = Unable to find FQDN '{1}' on the edge server '{0}' external certificate subject alternative name list.
	IDEdgeConfigDoNotAllowDnsSrvRouting              = EnablePartnerDiscovery is currently disabled.
	IDEdgeConfigDoNotAllowFederatedUsers             = Federated user access is disabled.
	IDEdgeConfigDoNotAllowOutsideUsers               = Remote user access is disabled.
	IDEdgeServerNotListening                         = The edge server, '{0}', is not listening on the remote TCP port 5985.
	IDEdgeServerNotReachable                         = The edge server, '{0}', is not returning the echo response replies to the ICMP echo requests packets or pings.
	IDEdgeServerWrongExternalSipPort                 = Unable to validate the port being used for External SIP connections. Either the edge server is unreachable or the port has the incorrect value.
	IDException                                      = An Exception has occurred while running the diagnostic script: {0}
	IDExchangeAutodiscoverUrlNotConfigured           = Autodiscover URL is not well formed for Exchange On-Premise. Expected '{0}' but got '{1}'
	IDExternalDNSResolutionFailed                    = Attempting to resolve sipfed.online.lync.com DNS A record failed.
	IDExternalWSNotInSPNList                         = External web service does not exist in Service Principal Names (SPN) list
	IDFileDoesNotExist                               = Unable to locate file '{0}'
	IDFileIsEmpty                                    = '{0}' is empty.
	IDFrontendFqdnCertNotOnSan                       = Unable to find FQDN of the local server in Skype for Business Server certificate.
	IDGetCsOnlineSipDomainFails                      = Call to Get-CsOnlineSipDomain has failed
	IDGetCsServerVersionFailed                       = Call to Get-CsServerVersion has failed.
	IDGetCsServiceFails                              = Unable to return information about the services and server roles being used in your Skype for Business Server infrastructure
	IDGetCsTenantFails                               = Unable to detect specified domain in Microsoft 365 cloud-based services.
	IDHybridAuthFound                                = The On-Premise and online authentication schemes are not the same. This scenario is not supported.
	IDIncorrectFederatedDomainSrvRecord              = Remote federation SRV record does not exist or is incorrect.
	IDIncorrectFederationRoute                       = Topology needs to have at least one and just one Federated Edge Server.
	IDIncorrectLocalFederationDnsSrvRecord           = Federation SRV record for local SIP domain does not exist or is incorrect.
	IDIncorrectServerVersion                         = Server version mis-match. Expected {0} or higher but found {1}.
	IDIPAddressNotInPool                             = Unable to locate local machine's IP address, {0}, in list of addresses, {1}, associated with Pool FQDN
	IDIPv4DoesNotMatchReverseLookup                  = DNS IPv4 name does not match reverse DNS IP address {0} lookup. Expected: {1}, Actual: {2}
	IDIsNotSfbServerFrontend                         = Skype for Business Server Frontend role is not installed. This usually indicates that this not a Skype for Business Server frontend machine.
	IDLegacyModernAuthDetected                       = The server is using legacy Modern Authentication, which is not recommended.
	IDListenAllNotFound                              = Server isn’t configured to listen on all IP Addresses.
	IDLocalCertStoreNotFound                         = The local machine certificate store is either missing or unavailable.
	IDLocalSQLServerSchemaVersionMismatch            = The Skype for Business Server local database: '{0}', installed version: '{1}', does not match expected version: '{2}'.
	IDLogSpaceThreshold                              = SQL server transaction logs on {0} at {1} are exceeding warning threshold. Expected a value of {2}% or less, actual value is {3}%
	IDLyncServerFound                                = No Skype for Business Servers services were found in your topology.
	IDMissingOAuthCertificate                        = Unable to locate a OAuthTokenIssuer certificate
	IDModernAuthNotEnabled                           = EvoSTS Authorization Server Object is missing.
	IDModernAuthSfboNotEnabled                       = Tenant Modern authentication is not configured. Expected ClientAdalAuthOverride value '{0}' but found '{1}'.
	IDMultiHomePossible                              = A possible multi-home configuration was found. We expected to get a count of 1 IP address bound to the NIC but found {0} instead.
	IDNameResolutionFails                            = The server name returned should match the registrar name. Expected: {0}, Actual: {1}
	IDNoCertificatesFound                            = No certificates were found in the local machine certificate store.
	IDNoClientAccessServerRole                       = Unable to determine the client access server role for the Exchange service
	IDNoDefaultSipDomainFound                        = Unable to locate any information regarding SIP domains.
	IDNoDNSRecordFound                               = No DNS record was found.
	IDNoEdgePoolsFound                               = No Edge pools were found.
	IDNoEdgeServersFound                             = No edge server was found for this configuration.
	IDNoExchangeConnectivity                         = Test-CsExStorageConnectivity cmdlet that verifies if Skype for Business Server Storage service can communicate with Exchange Server failed for SIP user {0}
	IDNoIPAddressForHostName                         = A DNS record was found for '{0}', but there is no IP address associated with it
	IDNoLogSpace                                     = Not able to identify available transaction log space for database {1} associated to {0} data source.
	IDNoMonitoringRole                               = Monitoring role not installed/detected
	IDNoOauthConfigurationFound                      = Unable to obtain Exchange AutodiscoverUrl value.
	IDNoOAuthServer                                  = No output returned by Get-CsAuthServer cmdlet
	IDNoPartnerApplication                           = Unable to locate Exchange partner application information.
	IDNoPoolIPAddresses                              = Unable to resolve Frontend End pool FQDN IP DNS records.
	IDNoRegistrarServerFound                         = No Registrar server is configured as next hop pool for the {0} Edge Server pool.
	IDNoReplicationStatus                            = Unable to get information about the Skype for Business Server replication process. This includes information on whether replication is currently up to date for your Skype for Business Server computers.
	IDNoServicePrincipalNames                        = Unable to get service principal name information
	IDNoSession                                      = Unable to establish a connection with '{0}'
	IDNoSIPAddress                                   = Lookup failed to find '{0}' SIP user.
	IDNoSIPProxyFqdnFound                            = Unable to locate the SIP hosting provider.
	IDNoSQLServiceInstancesFound                     = Unable to find any local SQL server instances for Skype for Business Server.
	IDNotAMemberOfSecurityGroup                      = The current user, '{0}',  does not have privileges to run the cmdlets required for this scenario.
	IDNoTenantIDFound                                = Get-CsOAuthServer cmdlet returned mismatched Metadata URL realm.
	IDNotFEMachine                                   = Current machine is not a FrontEnd server.
	IDNotOAuthServers                                = Get-CsOAuthConfiguration cmdlet returned an empty output.
	IDNoValidCertificates                            = No Skype for Business Server certificates have been found.
	IDNullOrEmptyPoolFQDN                            = The Pool FQDN, '{0}', is either null or empty.
	IDOAuthCertficateExpired                         = The OAuthTokenIssuer certificate has expired
	IDOAuthCertficateNoThumbprint                    = The OAuthTokenIssuer does not have a valid thumbprint
	IDOnlineOnPremAllowedDomainDoNotMatch            = The allowed federated domain configured in your On Premise environment, '{0}', and your O365 Tenant, '{1}', do not match.
	IDOnPremiseUsersFound                            = Skype for Business On-Premises users have been found
	IDPartnerApplicationDisabled                     = Exchange partner application returned by Get-CsPartnerApplication is disable.
	IDPatchUpdateAvailable                           = Out of date component found: {0} - Found {1} but {2} is available
	IDPoolFqdnCertNotOnSan                           = Unable to find Skype for Business pool FQDN in Skype for Business Server certificate.
	IDPropertyNotFoundException                      = Unable to locate property on object: {0}.
	IDProxyEnabled                                   = If your Skype for Business front-end servers use a proxy server for Internet access, the proxy server IP and Port number used must be entered in the configuration section of the web.config file for each front end.
	IDProxyMismatch                                  = If your Skype for Business front-end servers use a proxy server for Internet access, the proxy server IP and Port number used must be entered in the configuration section of '{0}'
	IDProxyShouldBeEmpty                             = Found a proxy host when there shouldn't be one: Domain: {0}, ProxyFqdn = {1}.
	IDRegistryKeyNotFound                            = Unable to locate registry key/value for '{0}'
	IDRGSUsageTrend                                  = Report Group Usage Report has timed out
	IDRootCACertificatesMisplaced                    = There are {0} certificates incorrectly stored on the local computer Trusted Root Certification Authorities store.
	IDSchannelSessionTicketNotDisabled               = Schannel session ticket TLS optimization is enabled. In earlier OS builds TLS problems may occur if TLS optimization is enabled.
	IDSchannelTrustModeNotSet                        = Schannel client authentication mode is not configured to 'exclusive CA trust'.
	IDServicePrincipalDoesNotExist                   = Unable to locate service principal name.
	IDSFBLocalDBsAreInSingleUserMode                 = The Skype for Business Server local database '{0}' is either single user mode or offline status.
	IDSfBOnlinePShellNotInstalled                    = Skype for Business Server PowerShell module is not installed
	IDSfbServerCertificateIsExpired                  = The Skype for Business Server certificate is either expired or not set.
	IDSfbServerNoQuorum                              = Only {0} out of {1} Skype for Business Server frontend seem to be running.
	IDSfbServerPowerShellModuleNotLoaded             = The Skype for Business Server PowerShell module is not loaded. This usually indicates that this not a Skype for Business Server frontend machine.
	IDSipDomainNotFederated                          = The specified user domain is not a verified Microsoft 365 domain.
	IDSIPHostingProviderAutodiscoverURLInvalid       = Office 365 hosting provider Autodiscover parameter value is incorrect.
	IDSIPHostingProviderNotEnabled                   = The hosting provider required for Office 365 Federation is not enabled.
	IDSIPHostingProviderNotFound                     = The hosting provider required for Office 365 Federation is missing.
	IDSIPHostingProviderSharedAddressSpaceEnabled    = Shared SIP address space is enabled so this is configured as an hybrid environment.
	IDSIPHostingProviderSharedAddressSpaceNotEnabled = Shared SIP address space required for federation with Office 365 is disabled.
	IDSIPSharedAddressSpaceEnabled                   = Shared SIP address space is enabled so this is still configured as an hybrid environment.
	IDSQLServerBackendConnectionIsDown               = The Skype for Business Server SQL back end connectivity to '{0}' is not available.
	IDSQLServicesNotRunning                          = At least one local SQL Server service is not started.
	IDSSLNotDisabled                                 = {0} not configured correctly. DisabledByDefault: Expected: 1, Actual: {1}, Enabled: Expected: 0, Actual: {2}
	IDStrongCryptoNotSet                             = SchUseStrongCrypto for .NET Framework {0} not properly set. Expected: {1}, Actual: {2}
	IDTeamsModuleNotLoaded                           = MicrosofTeams 2.0.0, or later, is required to be installed and loaded
	IDTestCsDatabaseNoResults                        = Unable to verify connectivity to one or more Skype for Business Server databases.
	IDTestNetworkConnectionFails                     = Unable to verify network connection with '{0}'.
	IDTLSNotEnabled                                  = {0} not configured correctly. DisabledByDefault: Expected: 0, Actual: {1}, Enabled: Expected: 1, Actual: {2}
	IDTooManyCertsInRootCA                           = There are {0} certificates in local computer 'Trusted Root Certification Authorities' store.
	IDUCSConnectivityNotAvailable                    = Server-to-Server authentication between Skype for Business and Exchange is either not configured or the connection is currently down. Note: If user contact list is expected to be empty this error is expected.
	IDUnableToConnect                                = Unable to connect to server '{0}'. The most likely cause of this issue is that either the server is unreachable or the user does not have the required permissions.
	IDUnableToConnectToAAD                           = Unable to establish connection with Azure Active Directory (AAD)
	IDUnableToConnectToEdgeServer                    = Unable to connect to edge server '{0}'. The most likely cause of this issue is that either the server is unreachable or the user does not have the required permissions.
	IDUnableToGetOAuthConfiguration                  = Get-CsOAuthConfiguration cmdlet returned an error or an empty output.
	IDUnableToGetProductName                         = Unable to locate 'Core Component'
	IDUnableToGetRemoteCertificate                   = Unable to obtain remote certificate from server '{0}'
	IDUnableToGetServiceInfo                         = Unable to get information about the services and server roles being used in your Skype for Business Server infrastructure.
	IDUnableToGetVersion                             = Unable to determine current patch level on the server.
	IDUnableToImportExchangeCmdlets                  = Unable to import the Exchange cmdlets from the Exchange server '{0}'.
	IDUnableToImportRemoteSession                    = Unable to establish a remote session with server '{0}'
	IDUnableToResolveDNSName                         = Unable to resolve DNS query for one or more of your Skype for Business Server server(s).
	IDUnableToResolveServerFQDN                      = Unable to resolve the FQDN for your Skype for Business Server.
	IDUnableToRetrieveSSLSettings                    = Unable to retrieve SSL settings
	IDUnableToRetrieveTLSSettings                    = Unable to retrieve TLS settings
	IDUnknownDomain                                  = Unable to determine the user DNS domain
	IDUserNotFound                                   = Unable to locate user '{0}' or it does not exist.
	IDUserNotUCSEnabled                              = The following user account: '{0}' is not enabled for Unified Contact Store.
	IDUsersValidationErrorFound                      = Microsoft 365 users with validation errors have been found
	IDUserUCSEnabledNotMigrated                      = User contact list is ready to be migrated however that can only be completed when user signs-in.
	IDWinHttpSecureProtocols                         = WinHTTP ({0}) 'DefaultSecureProtocol' has incorrect value. Expected: 2720 (0xAA0), Actual: {1} ({2})
	IDWrongMetadataUrlConfiguration                  = Wrong partner application AuthToken Metadata configuration detected. Expected '{0}' but got '{1}'
	IDWrongOnlineMetadataUrlConfiguration            = Wrong partner application AuthToken Metadata configuration detected. Expected '{0}' but got '{1}'
	IDWrongPartnerApplication                        = Microsoft.Exchange partner application is registered for an incorrect service name.
	IDWrongVerificationLevel                         = Office 365 hosting provider VerificationLevel parameter value is incorrect.
'@
