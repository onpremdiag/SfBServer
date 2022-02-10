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
# Filename: RuleDescriptions.psd1
# Description: Localized rule descriptions
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 3/1/2021 1:38 PM
#
# Last Modified On: 3/1/2021 1:44 PM
#################################################################################
ConvertFrom-StringData @'
###PSLOC
	RDAllowFederatedPartners                 = Determine if open federation is enabled for On-Premise and Office 365 tenant
	RDAllowFederatedUsers                    = Determine if the Office 365 tenant Skype federation is enabled
	RDAutoDiscoverServiceInternalUri         = Determine if the AutoDiscoverServiceInternalUri value contains a valid configuration
	RDCheckAddressInPool                     = Determine if current machine is in list of addresses for the pool
	RDCheckAutoDiscoverURL                   = Determine if the SkypeforBusinessOnline hosting provider AutodiscoverURL is valid
	RDCheckCMSReplicationStatus              = Determine if Central Management Store replication is up to date
	RDCheckDirSyncEnabled                    = Determine if Directory Sync is enabled
	RDCheckDNSResolution                     = Determine if the IPv4 address can be resolved and the reverse lookup matches
	RDCheckDomainApprovedForFederation       = Determine if open federation is enabled or target domain is approved for federation
	RDCheckEdgeCerts                         = Determine if Edge servers external certificate meet basic requirements
	RDCheckEdgeExternalDNS                   = Determine if edge server allows external DNS resolution
	RDCheckEdgeInternalDNS                   = Determine if edge server can resolve next hop pool FQDN for each frontend server
	RDCheckEdgePoolCount                     = Determine if just one edge pool is enabled for federation
	RDCheckFederatedDomainDNSRecords         = Determine if federated domain DNS SRV is discoverable
	RDCheckForLyncServers                    = Determine if there are any Lync servers in the topology
	RDCheckForProxy                          = Determine if proxy is being used (no direct connection)
	RDCheckListenAll                         = Determine if the server is configured to listen on all IP Addresses
	RDCheckLocalDBVersionMismatch            = Determine if local databases version match expected version
	RDCheckLocalDomainFederationDNSRecord    = Determine if local domain federation DNS SRV record is discoverable
	RDCheckLocalSQLServerSchemaVersion       = Determine if local SQL Server database installed version is different than expected version
	RDCheckLyncdiscoverRecord                = Determine if lyncdiscover.<domain> DNS CNAME record points to webdir.online.lync.com
	RDCheckMisplacedRootCACertificates       = Determine if there are misplaced certificates in local machine Root system store
	RDCheckModernAuth                        = Determine if Modern Authentication is being used
	RDCheckMultihomedServer                  = Determine if the server is multi-homed
	RDCheckOAuthIsConfigured                 = Determine if OAuth is configured (at least 1 OAuthServer)
	RDCheckOnlineSharedSipAddressSpace       = Determine if the SkypeforBusinessOnline hosting provider SharedAddressSpace is enabled
	RDCheckPatchVersion                      = Determine if the server is at, or above, currently recommended patch level(s)
	RDCheckProxyConfiguration                = Determine if proxy settings are in sync/correct
	RDCheckProxyFQDN                         = Determine if the Office 365 hosting provider ProxyFqdn is correct
	RDCheckProxyPostMigration                = Determine if ProxyFqdn needs to be updated because federated partner has migrated from On-Premise to Online
	RDCheckSchannelSessionTicket             = Determine if Schannel session ticket TLS optimization is enabled
	RDCheckSchannelTrustMode                 = Determine if Schannel client authentication trust mode registry key is set to exclusive CA
	RDCheckServerVersion                     = Determine if the current product version is compatible with the Web Component Server
	RDCheckServicePoints                     = Determine if TLS connectivity to O365 and CRLs reachable
	RDCheckSFBLocalDBsSingleUserMode         = Determine if local Skype for Business Server databases are in single user mode
	RDCheckSfbServerAccountAdminRights       = Determine if current account has Skype for Business Server administrative privileges
	RDCheckSfbServerCertificateExpired       = Determine if Skype for Business Server Frontend certificate is expired
	RDCheckSfbServerCertificateValid         = Determine if the certificates on the Front End and Pool server are valid
	RDCheckSfbServerQuorumLoss               = Determine if minimum number of frontend servers required to start pool are available
	RDCheckSharedAddressSpace                = Determine if the SkypeforBusinessOnline hosting provider SharedAddressSpace is enabled
	RDCheckSharedAddressSpaceNotEnabled      = Determine if the SkypeforBusinessOnline hosting provider SharedAddressSpace is disabled
	RDCheckSipDomainIsFederated              = Determine if the SIP domain is federated/managed
	RDCheckSipFedSRVRecords                  = Determine if _sipfederationtls._tcp.<sipdomain> DNS SRV record points to sipfed.online.lync.com
	RDCheckSipRecord                         = Determine if sip.<domain> DNS CNAME record points to sipdir.online.lync.com
	RDCheckSipTLSSRVRecords                  = Determine if _sip._tls.<sipdomain> DNS SRV record points to sipdir.online.lync.com
	RDCheckSQLLogs                           = Determine if the SQL server transaction logs are too large
	RDCheckSQLServerBackendConnection        = Determine if SQL Server back end connectivity is available
	RDCheckSQLServicesAreRunning             = Determine if local SQL Server services are running
	RDCheckSQLVersion                        = Determine if the appropriate version of SQL is installed for TLS 1.2
	RDCheckSSLSettings                       = Determine if the SSL 3.0/2.0 settings have been properly configured for TLS 1.0/1.1 deprecation
	RDCheckTenantModernAuthEnabled           = Determine if Tenant Modern Authentication is enabled
	RDCheckTLSSettings                       = Determine if the TLS 1.2, or better, has been properly enabled
	RDCheckTooManyCertsRootCA                = Determine if there are too many certificates in local machine root CA store
	RDCheckUserUCSConnectivity               = Determine if user contact list can be effectively retrieved from Exchange Server
	RDCheckUserUCSStatus                     = Determine if user account is enabled for unified contact store and user account has been migrated successfully
	RDCheckUseStrongCrypto                   = Determine if SchUseStrongCrypto is set correctly for TLS 1.2
	RDCheckVerificationLevel                 = Determine if the SIP hosting provider messages verification level is set correctly
	RDCheckWinHttpSettings                   = Determine if the WinHTTP settings have been properly configured for TLS 1.0/1.1 deprecation.
	RDCompareAllowedDomains                  = Determine if the On-Premise domains configuration match Office 365 tenant domain configuration
	RDCsPartnerApplication                   = Determine if the partner application exists and is configured with the proper value
	RDDuplicatesInTrustedRootCA              = Determine if there are duplicate certificates in the trusted root certification authority
	RDEdgeConfigAllowFederatedUsers          = Determine if remote user access is enabled
	RDEdgeConfigAllowOutsideUsers            = Determine if the edge configuration allows outside users
	RDEdgeConfigUseDnsSrvRouting             = Determine if the edge is configured for open federation
	RDEdgeServerAvailable                    = Determine if the edge server is reachable (ping)
	RDEdgeServerListening                    = Determine if the edge server is listening on port 5985
	RDExchangeAutodiscoverUrl                = Determine if the OAuth ExchangeAutodiscoverUrl is well configured
	RDExchangePowerShellCmdletsLoaded        = Determine if the Exchange cmdlets are loaded. If not, load them.
	RDIsHostingProviderEnabled               = Determine if hosting provider required to communicate with Skype for Business Online is enabled
	RDIsSfbServerFrontend                    = Determine if Skype for Business Frontend Server role is installed on local machine
	RDIsUniversalServerAdmin                 = Determine if the current user has administrative privileges to run cmdlets
	RDNoOnPremiseUsers                       = Determine if there are any On-Premise users still present
	RDOAuthCertificateValid                  = Determine if the OAuthTokenIssuer certificate has not expired and has a serial number
	RDSfbServerPowerShellModuleLoaded        = Determine if this is a Skype for Business Server PowerShell module is loaded
	RDSharedSipAddressSpace                  = Determine if the Office 365 tenant shared SIP address space is enabled
	RDTeamsModuleLoaded                      = Determine if the required version MicrosoftTeams module is loaded
	RDTestAppPrincipalExists                 = Determine if the app principal ID exists
	RDTestAutoDiscover                       = Determine if the DNS name for the Autodiscover is resolvable
	RDTestExchangeCertificateForAutodiscover = Determine if the Exchange On-Premise certificate SAN is configured for autodiscovery or wildcard
	RDTestExchangeConnectivity               = Determine if the Skype for Business Server Storage Service is working on a Front End Server
	RDTestOAuthServerConfiguration           = Determine if the OAuthServer configuration is correct
	RDTestPartnerApplication                 = Determine if the Exchange application service exists and has the correct values
	RDUsageTrend                             = Determine if the Usage Report returns results in the expected time limit (60 sec)
###PSLOC
'@
