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
# Filename: EventIDs.psd1
# Description: Event ids used by Skype for Business Server scenarios, analyzers,
# and rules.
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 3/1/2021 1:10 PM
#
# Last Modified On: 3/1/2021 1:11 PM
#################################################################################
@{
    ADBestPractices                                 = 9633
    ADCertificateCheck                              = 9617
    ADCheckAADConfigured                            = 9630
    ADCheckAllServersSkype                          = 9627
    ADCheckDomainIsKnown                            = 9629
    ADCheckEdgeConfiguration                        = 9602
    ADCheckEdgeInternalDNS                          = 9623
    ADCheckEdgeOnPremConfiguration                  = 9620
    ADCheckEdgePoolConfiguration                    = 9603
    ADCheckFederatedDomain                          = 9619
    ADCheckFederationDNSRecords                     = 9621
    ADCheckHybridDeployment                         = 9635
    ADCheckLocalSQLServerInstanceAndDBs             = 9610
    ADCheckModernAuthentication                     = 9632
    ADCheckO365Connectivity                         = 9628
    ADCheckProxy                                    = 9622
    ADCheckQuorumLoss                               = 9611
    ADCheckRegistrarVersions                        = 9631
    ADCheckRootCACertificates                       = 9612
    ADCheckSChannelRegistryKeys                     = 9613
    ADCheckSecurityGroupMembership                  = 9604
    ADCheckSFBVersion                               = 9641
    ADCheckSIPHostingProvider                       = 9605
    ADCheckSIPHostingProviderForOnPrem              = 9618
    ADCheckSSLSettings                              = 9638
    ADCheckStrongCryptoEnabled                      = 9640
    ADCheckTLSSettings                              = 9637
    ADCheckUserUCS                                  = 9601
    ADCheckWinHttp                                  = 9639
    ADCompareOnPremToOnline                         = 9606
    ADEdgeServerAvailable                           = 9616
    ADExchangeHybrid                                = 9626
    ADExchangeOnline                                = 9625
    ADExchangeOnPremise                             = 9624
    ADIsSfbServerAdminAccount                       = 9607
    ADIsSfbServerCertificateValid                   = 9614
    ADIsSfbServerFrontend                           = 9608
    ADIsSQLBackendConnectionAvailable               = 9615
    ADIsTeamsModuleLoaded                           = 9634
    ADRGSUsageTrend                                 = 9636
    ADSfbServerPowerShellModuleLoaded               = 9609
    RDAllowFederatedPartners                        = 9703
    RDAllowFederatedUsers                           = 9704
    RDAutoDiscoverServiceInternalUri                = 9744
    RDCheckAddressInPool                            = 9759
    RDCheckAutoDiscoverURL                          = 9705
    RDCheckCMSReplicationStatus                     = 9706
    RDCheckDirSyncEnabled                           = 9768
    RDCheckDNSResolution                            = 9740
    RDCheckDomainApprovedForFederation              = 9736
    RDCheckEdgeCerts                                = 9734
    RDCheckEdgeExternalDNS                          = 9737
    RDCheckEdgeInternalDNS                          = 9742
    RDCheckEdgePoolCount                            = 9707
    RDCheckFederatedDomainDNSRecords                = 9738
    RDCheckForLyncServers                           = 9760
    RDCheckForProxy                                 = 9741
    RDCheckListenAll                                = 9758
    RDCheckLocalDBVersionMismatch                   = 9708
    RDCheckLocalDomainFederationDNSRecord           = 9739
    RDCheckLocalSQLServerSchemaVersion              = 9722
    RDCheckLyncdiscoverRecord                       = 9775
    RDCheckMisplacedRootCACertificates              = 9723
    RDCheckModernAuth                               = 9766
    RDCheckMultiHomedServer                         = 9757
    RDCheckOAuthIsConfigured                        = 9767
    RDCheckOnlineSharedSipAddressSpace              = 9777
    RDCheckPatchVersion                             = 9755
    RDCheckProxyConfiguration                       = 9769
    RDCheckProxyFQDN                                = 9709
    RDCheckProxyPostMigration                       = 9763
    RDCheckSchannelSessionTicket                    = 9724
    RDCheckSchannelTrustMode                        = 9725
    RDCheckServerVersion                            = 9761
    RDCheckServicePoints                            = 9762
    RDCheckSFBLocalDBsSingleUserMode                = 9726
    RDCheckSfbServerAccountAdminRights              = 9718
    RDCheckSfbServerCertificateExpired              = 9727
    RDCheckSfbServerCertificateValid                = 9764
    RDCheckSfbServerQuorumLoss                      = 9728
    RDCheckSharedAddressSpace                       = 9710
    RDCheckSharedAddressSpaceNotEnabled             = 9735
    RDCheckSipDomainIsFederated                     = 9765
    RDCheckSipFedSRVRecords                         = 9773
    RDCheckSipRecord                                = 9776
    RDCheckSipTLSSRVRecords                         = 9774
    RDCheckSQLLogs                                  = 9756
    RDCheckSQLServerBackendConnection               = 9729
    RDCheckSQLServicesAreRunning                    = 9730
    RDCheckSQLVersion                               = 9783
    RDCheckSSLSettings                              = 9780
    RDCheckTenantModernAuthEnabled                  = 9770
    RDCheckTLSSettings                              = 9779
    RDCheckTooManyCertsRootCA                       = 9731
    RDCheckUserUCSConnectivity                      = 9701
    RDCheckUserUCSStatus                            = 9702
    RDCheckUseStrongCrypto                          = 9782
    RDCheckVerificationLevel                        = 9711
    RDCheckWinHttpSettings                          = 9781
    RDCompareAllowedDomains                         = 9712
    RDCsPartnerApplication                          = 9746
    RDDuplicatesInTrustedRootCA                     = 9754
    RDEdgeConfigAllowFederatedUsers                 = 9713
    RDEdgeConfigAllowOutsideUsers                   = 9714
    RDEdgeConfigUseDnsSrvRouting                    = 9715
    RDEdgeServerAvailable                           = 9733
    RDEdgeServerListening                           = 9732
    RDExchangeAutodiscoverUrl                       = 9745
    RDExchangePowerShellCmdletsLoaded               = 9750
    RDIsHostingProviderEnabled                      = 9716
    RDIsSfbServerFrontend                           = 9719
    RDIsUniversalServerAdmin                        = 9720
    RDNoOnPremiseUsers                              = 9772
    RDOAuthCertificateValid                         = 9748
    RDSfbServerPowerShellModuleLoaded               = 9721
    RDSharedSipAddressSpace                         = 9717
    RDTeamsModuleLoaded                             = 9771
    RDTestAppPrincipalExists                        = 9752
    RDTestAutoDiscover                              = 9743
    RDTestExchangeCertificateForAutodiscover        = 9751
    RDTestExchangeConnectivity                      = 9747
    RDTestOAuthServerConfiguration                  = 9749
    RDTestPartnerApplication                        = 9753
    RDUsageTrend                                    = 9778
    SDBestPractices                                 = 9515
    SDCheckSfbServerSupportability                  = 9503
    SDExchangeHybridIntegrationNotWorking           = 9514
    SDExchangeIntegrationFailing                    = 9504
    SDExchangeOnlineIntegrationNotWorking           = 9513
    SDExchangeOnPremiseIntegrationNotWorking        = 9512
    SDHybridDeploymentProperlyDisabled              = 9516
    SDHybridFederation                              = 9511
    SDModernAuthenticationNotWorking                = 9505
    SDOnPremFederation                              = 9510
    SDPresenceAndIMDelay                            = 9509
    SDPresenceIMNotWorking                          = 9506
    SDResponseGroupUsageReport                      = 9517
    SDSfbServerFrontendServiceNotStarting           = 9508
    SDSfbServerPSModuleLoadedAndIsFrontend          = 9507
    SDTLSDeprecation                                = 9518
    SDUserContactCardPhoneNumberNotAvailable        = 9501
    SDUserContactListIsMissing                      = 9502
}
