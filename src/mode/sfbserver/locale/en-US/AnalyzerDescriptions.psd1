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
# Filename: AnalyzerDescriptions.psd1
# Description: Localized analyzer descriptions
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 3/1/2021 1:21 PM
#
# Last Modified On: 3/1/2021 1:44 PM
#################################################################################
ConvertFrom-StringData @'
###PSLOC
	ADBestPractices                     = Verifies server is configured with the latest updates, recommendations and best practices
	ADCertificateCheck                  = Verifies if Edge servers external certificate meet basic requirements
	ADCheckAADConfigured                = Verifies if the Azure Active Directory (AAD) connection is properly configured
	ADCheckAllServersSkype              = Verifies that all the registrars in the topology are Skype for Business 2015 or later
	ADCheckDomainIsKnown                = Verifies that the user's domain is registered with Azure Active Directory (AAD)
	ADCheckEdgeConfiguration            = Verifies the edge pool configuration for hybrid deployment
	ADCheckEdgeInternalDNS              = Verifies if the edge server can resolve the next hop pool FQDN for each frontend
	ADCheckEdgeOnPremConfiguration      = Verifies the edge pool configuration for On-Premise deployment
	ADCheckEdgePoolConfiguration        = Verifies the edge pool configuration is correct
	ADCheckFederatedDomain              = Verifies if target domain is approved for federation
	ADCheckFederationDNSRecords         = Verifies the federation DNS records requirements
	ADCheckHybridDeployment             = Verifies if Skype for Business Hybrid deployment was properly disabled
	ADCheckLocalSQLServerInstanceAndDBs = Verifies if local SQL Server instances are running, databases are not in single user mode and schema version is correct
	ADCheckModernAuthentication         = Verifies if Modern Authentication has been enabled
	ADCheckO365Connectivity             = Verifies that the connectivity from the registrar to required O365 URLs is available
	ADCheckProxy                        = Verifies if proxy server is being used
	ADCheckQuorumLoss                   = Verifies if minimum required number of servers to have quorum are up and running
	ADCheckRegistrarVersions            = Verifies that the Skype for Business servers are at the proper version
	ADCheckRootCACertificates           = Verifies the local machine certificate store configuration is correct
	ADCheckSChannelRegistryKeys         = Verifies the schannel client authentication trust mode and session ticket TLS optimization registry keys configuration
	ADCheckSecurityGroupMembership      = Verifies if account has Skype for Business Server administrative privileges
	ADCheckSIPHostingProvider           = Verifies the SIP Hosting Provider settings for hybrid deployment
	ADCheckSIPHostingProviderForOnPrem  = Verifies the SIP Hosting Provider settings for On-Premise deployment
	ADCheckTLSSettings                  = Verifies TLS 1.0/1.1 deprecation
	ADCheckUserUCS                      = Verifies if user contact list is being accessed through Unified Contact Store
	ADCompareOnPremToOnline             = Verifies the On-Premise domains configuration match Office 365 tenant domain configuration
	ADEdgeServerAvailable               = Verifies that the Edge Server is available for remote PowerShell connections
	ADExchangeHybrid                    = Verifies that connectivity with Exchange (hybrid configuration) is configured correctly
	ADExchangeOnline                    = Verifies that connectivity with Exchange Online is configured correctly
	ADExchangeOnPremise                 = Verifies that connectivity with Exchange On-Premise is configured correctly
	ADIsSfbServerAdminAccount           = Verifies if account has Skype for Business Server administrative privileges
	ADIsSfbServerCertificateValid       = Verifies if Skype for Business Server Frontend certificate is not expired
	ADIsSfbServerFrontend               = Verifies if Skype for Business Server frontend role is installed on this machine
	ADIsSQLBackendConnectionAvailable   = Verifies the SQL Server back end connectivity
	ADIsTeamsModuleLoaded               = Verifies that the minimum version MicrosoftTeams module is loaded
	ADRGSUsageTrend                     = Verifies that the Response Group Usage Report is working properly
	ADSfbServerPowerShellModuleLoaded   = Verifies that the Skype for Business PowerShell module is loaded
	ADSQLDBVersionMismatch              = Verifies if Skype for Business Server local databases match expected version
	ADCheckSSLSettings                  = Verifies SSL 3.0/2.0 are properly configured for TLS 1.1/1.0 deprecation
	ADCheckWinHttp                      = Verifies WinHTTP protocol settings for TLS 1.2 compliance
	ADCheckStrongCryptoEnabled          = Verifies SchUseStrongCrypt is set properly for .NET framework(s)
	ADCheckSFBVersion                   = Verifies that the minimum version of Skype for Business Server is installed
###PSLOC
'@
