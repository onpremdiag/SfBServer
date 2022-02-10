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
# Filename: SharePointMocks.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/12/2018 4:51 PM
#
# Last Modified On: 6/13/2019 1:59 PM
#################################################################################
Set-StrictMode -Version Latest

Add-Type -TypeDefinition @"
namespace Microsoft.SharePoint.Utilities
{
    public class SPUtility
    {
        public static string GetCurrentGenericSetupPath(string Path)
        {
            return "C:\\Program Files\\Common Files\\Microsoft Shared\\Web Server Extensions\\16\\";
        }
    }
}
"@

Add-Type -TypeDefinition @"
namespace Microsoft.SharePoint.Administration
{
    public enum SPObjectStatus
    {
        Online         = 0,
        Disabled       = 1,
        Offline        = 2,
        Unprovisioning = 3,
        Provisioning   = 4,
        Upgrading      = 5,
    }
}
"@


function Add-DatabaseToAvailabilityGroup
{
    # Mock stub for Add-DatabaseToAvailabilityGroup
}

function Add-SPAppDeniedEndpoint
{
    # Mock stub for Add-SPAppDeniedEndpoint
}

function Add-SPClaimTypeMapping
{
    # Mock stub for Add-SPClaimTypeMapping
}

function Add-SPDiagnosticsPerformanceCounter
{
    # Mock stub for Add-SPDiagnosticsPerformanceCounter
}

function Add-SPDistributedCacheServiceInstance
{
    # Mock stub for Add-SPDistributedCacheServiceInstance
}

function Add-SPInfoPathUserAgent
{
    # Mock stub for Add-SPInfoPathUserAgent
}

function Add-SPPluggableSecurityTrimmer
{
    # Mock stub for Add-SPPluggableSecurityTrimmer
}

function Add-SPProfileLeader
{
    # Mock stub for Add-SPProfileLeader
}

function Add-SPProfileSyncConnection
{
    # Mock stub for Add-SPProfileSyncConnection
}

function Add-SPRoutingMachineInfo
{
    # Mock stub for Add-SPRoutingMachineInfo
}

function Add-SPRoutingMachinePool
{
    # Mock stub for Add-SPRoutingMachinePool
}

function Add-SPRoutingRule
{
    # Mock stub for Add-SPRoutingRule
}

function Add-SPScaleOutDatabase
{
    # Mock stub for Add-SPScaleOutDatabase
}

function Add-SPSecureStoreSystemAccount
{
    # Mock stub for Add-SPSecureStoreSystemAccount
}

function Add-SPServerScaleOutDatabase
{
    # Mock stub for Add-SPServerScaleOutDatabase
}

function Add-SPServiceApplicationProxyGroupMember
{
    # Mock stub for Add-SPServiceApplicationProxyGroupMember
}

function Add-SPShellAdmin
{
    # Mock stub for Add-SPShellAdmin
}

function Add-SPSiteSubscriptionFeaturePackMember
{
    # Mock stub for Add-SPSiteSubscriptionFeaturePackMember
}

function Add-SPSiteSubscriptionProfileConfig
{
    # Mock stub for Add-SPSiteSubscriptionProfileConfig
}

function Add-SPSolution
{
    # Mock stub for Add-SPSolution
}

function Add-SPThrottlingRule
{
    # Mock stub for Add-SPThrottlingRule
}

function Add-SPUserLicenseMapping
{
    # Mock stub for Add-SPUserLicenseMapping
}

function Add-SPUserSolution
{
    # Mock stub for Add-SPUserSolution
}

function Backup-SPConfigurationDatabase
{
    # Mock stub for Backup-SPConfigurationDatabase
}

function Backup-SPEnterpriseSearchServiceApplicationIndex
{
    # Mock stub for Backup-SPEnterpriseSearchServiceApplicationIndex
}

function Backup-SPFarm
{
    # Mock stub for Backup-SPFarm
}

function Backup-SPSite
{
    # Mock stub for Backup-SPSite
}

function Clear-SPAppDeniedEndpointList
{
    # Mock stub for Clear-SPAppDeniedEndpointList
}

function Clear-SPBusinessDataCatalogEntityNotificationWeb
{
    # Mock stub for Clear-SPBusinessDataCatalogEntityNotificationWeb
}

function Clear-SPDistributedCacheItem
{
    # Mock stub for Clear-SPDistributedCacheItem
}

function Clear-SPLogLevel
{
    # Mock stub for Clear-SPLogLevel
}

function Clear-SPMetadataWebServicePartitionData
{
    # Mock stub for Clear-SPMetadataWebServicePartitionData
}

function Clear-SPPerformancePointServiceApplicationTrustedLocation
{
    # Mock stub for Clear-SPPerformancePointServiceApplicationTrustedLocation
}

function Clear-SPScaleOutDatabaseDeletedDataSubRange
{
    # Mock stub for Clear-SPScaleOutDatabaseDeletedDataSubRange
}

function Clear-SPScaleOutDatabaseLog
{
    # Mock stub for Clear-SPScaleOutDatabaseLog
}

function Clear-SPScaleOutDatabaseTenantData
{
    # Mock stub for Clear-SPScaleOutDatabaseTenantData
}

function Clear-SPSecureStoreCredentialMapping
{
    # Mock stub for Clear-SPSecureStoreCredentialMapping
}

function Clear-SPSecureStoreDefaultProvider
{
    # Mock stub for Clear-SPSecureStoreDefaultProvider
}

function Clear-SPServerScaleOutDatabaseDeletedDataSubRange
{
    # Mock stub for Clear-SPServerScaleOutDatabaseDeletedDataSubRange
}

function Clear-SPServerScaleOutDatabaseLog
{
    # Mock stub for Clear-SPServerScaleOutDatabaseLog
}

function Clear-SPServerScaleOutDatabaseTenantData
{
    # Mock stub for Clear-SPServerScaleOutDatabaseTenantData
}

function Clear-SPSiteSubscriptionBusinessDataCatalogConfig
{
    # Mock stub for Clear-SPSiteSubscriptionBusinessDataCatalogConfig
}

function Connect-SPConfigurationDatabase
{
    # Mock stub for Connect-SPConfigurationDatabase
}

function Convert-SPWebApplication
{
    # Mock stub for Convert-SPWebApplication
}

function Copy-SPAccessServicesDatabaseCredentials
{
    # Mock stub for Copy-SPAccessServicesDatabaseCredentials
}

function Copy-SPActivitiesToWorkflowService
{
    # Mock stub for Copy-SPActivitiesToWorkflowService
}

function Copy-SPBusinessDataCatalogAclToChildren
{
    # Mock stub for Copy-SPBusinessDataCatalogAclToChildren
}

function Copy-SPContentTypes
{
    # Mock stub for Copy-SPContentTypes
}

function Copy-SPSideBySideFiles
{
    # Mock stub for Copy-SPSideBySideFiles
}

function Copy-SPSite
{
    # Mock stub for Copy-SPSite
}

function Copy-SPTaxonomyGroups
{
    # Mock stub for Copy-SPTaxonomyGroups
}

function Disable-ProjectServerLicense
{
    # Mock stub for Disable-ProjectServerLicense
}

function Disable-SPAppAutoProvision
{
    # Mock stub for Disable-SPAppAutoProvision
}

function Disable-SPBusinessDataCatalogEntity
{
    # Mock stub for Disable-SPBusinessDataCatalogEntity
}

function Disable-SPFeature
{
    # Mock stub for Disable-SPFeature
}

function Disable-SPHealthAnalysisRule
{
    # Mock stub for Disable-SPHealthAnalysisRule
}

function Disable-SPInfoPathFormTemplate
{
    # Mock stub for Disable-SPInfoPathFormTemplate
}

function Disable-SPProjectActiveDirectoryEnterpriseResourcePoolSync
{
    # Mock stub for Disable-SPProjectActiveDirectoryEnterpriseResourcePoolSync
}

function Disable-SPProjectEmailNotification
{
    # Mock stub for Disable-SPProjectEmailNotification
}

function Disable-SPProjectEnterpriseProjectTaskSync
{
    # Mock stub for Disable-SPProjectEnterpriseProjectTaskSync
}

function Disable-SPProjectQueueStatsMonitoring
{
    # Mock stub for Disable-SPProjectQueueStatsMonitoring
}

function Disable-SPSessionStateService
{
    # Mock stub for Disable-SPSessionStateService
}

function Disable-SPSingleSignOn
{
    # Mock stub for Disable-SPSingleSignOn
}

function Disable-SPTimerJob
{
    # Mock stub for Disable-SPTimerJob
}

function Disable-SPUserLicensing
{
    # Mock stub for Disable-SPUserLicensing
}

function Disable-SPUserSolutionAllowList
{
    # Mock stub for Disable-SPUserSolutionAllowList
}

function Disable-SPWebApplicationHttpThrottling
{
    # Mock stub for Disable-SPWebApplicationHttpThrottling
}

function Disable-SPWebTemplateForSiteMaster
{
    # Mock stub for Disable-SPWebTemplateForSiteMaster
}

function Disconnect-SPConfigurationDatabase
{
    # Mock stub for Disconnect-SPConfigurationDatabase
}

function Dismount-SPContentDatabase
{
    # Mock stub for Dismount-SPContentDatabase
}

function Dismount-SPSiteMapDatabase
{
    # Mock stub for Dismount-SPSiteMapDatabase
}

function Dismount-SPStateServiceDatabase
{
    # Mock stub for Dismount-SPStateServiceDatabase
}

function Enable-ProjectServerLicense
{
    # Mock stub for Enable-ProjectServerLicense
}

function Enable-SPAppAutoProvision
{
    # Mock stub for Enable-SPAppAutoProvision
}

function Enable-SPBusinessDataCatalogEntity
{
    # Mock stub for Enable-SPBusinessDataCatalogEntity
}

function Enable-SPFeature
{
    # Mock stub for Enable-SPFeature
}

function Enable-SPHealthAnalysisRule
{
    # Mock stub for Enable-SPHealthAnalysisRule
}

function Enable-SPInfoPathFormTemplate
{
    # Mock stub for Enable-SPInfoPathFormTemplate
}

function Enable-SPProjectActiveDirectoryEnterpriseResourcePoolSync
{
    # Mock stub for Enable-SPProjectActiveDirectoryEnterpriseResourcePoolSync
}

function Enable-SPProjectEmailNotification
{
    # Mock stub for Enable-SPProjectEmailNotification
}

function Enable-SPProjectEnterpriseProjectTaskSync
{
    # Mock stub for Enable-SPProjectEnterpriseProjectTaskSync
}

function Enable-SPProjectQueueStatsMonitoring
{
    # Mock stub for Enable-SPProjectQueueStatsMonitoring
}

function Enable-SPSessionStateService
{
    # Mock stub for Enable-SPSessionStateService
}

function Enable-SPTimerJob
{
    # Mock stub for Enable-SPTimerJob
}

function Enable-SPUserLicensing
{
    # Mock stub for Enable-SPUserLicensing
}

function Enable-SPUserSolutionAllowList
{
    # Mock stub for Enable-SPUserSolutionAllowList
}

function Enable-SPWebApplicationHttpThrottling
{
    # Mock stub for Enable-SPWebApplicationHttpThrottling
}

function Enable-SPWebTemplateForSiteMaster
{
    # Mock stub for Enable-SPWebTemplateForSiteMaster
}

function Export-SPAccessServicesDatabase
{
    # Mock stub for Export-SPAccessServicesDatabase
}

function Export-SPAppPackage
{
    # Mock stub for Export-SPAppPackage
}

function Export-SPBusinessDataCatalogModel
{
    # Mock stub for Export-SPBusinessDataCatalogModel
}

function Export-SPEnterpriseSearchTopology
{
    # Mock stub for Export-SPEnterpriseSearchTopology
}

function Export-SPInfoPathAdministrationFiles
{
    # Mock stub for Export-SPInfoPathAdministrationFiles
}

function Export-SPMetadataWebServicePartitionData
{
    # Mock stub for Export-SPMetadataWebServicePartitionData
}

function Export-SPPerformancePointContent
{
    # Mock stub for Export-SPPerformancePointContent
}

function Export-SPScaleOutDatabaseTenantData
{
    # Mock stub for Export-SPScaleOutDatabaseTenantData
}

function Export-SPServerScaleOutDatabaseTenantData
{
    # Mock stub for Export-SPServerScaleOutDatabaseTenantData
}

function Export-SPSiteSubscriptionBusinessDataCatalogConfig
{
    # Mock stub for Export-SPSiteSubscriptionBusinessDataCatalogConfig
}

function Export-SPSiteSubscriptionSettings
{
    # Mock stub for Export-SPSiteSubscriptionSettings
}

function Export-SPTagsAndNotesData
{
    # Mock stub for Export-SPTagsAndNotesData
}

function Export-SPWeb
{
    # Mock stub for Export-SPWeb
}

function Get-AvailabilityGroupStatus
{
    # Mock stub for Get-AvailabilityGroupStatus
}

function Get-ProjectServerLicense
{
    # Mock stub for Get-ProjectServerLicense
}

function Get-SPAccessServiceApplication
{
    # Mock stub for Get-SPAccessServiceApplication
}

function Get-SPAccessServicesApplication
{
    # Mock stub for Get-SPAccessServicesApplication
}

function Get-SPAccessServicesDatabase
{
    # Mock stub for Get-SPAccessServicesDatabase
}

function Get-SPAccessServicesDatabaseServer
{
    # Mock stub for Get-SPAccessServicesDatabaseServer
}

function Get-SPAccessServicesDatabaseServerGroup
{
    # Mock stub for Get-SPAccessServicesDatabaseServerGroup
}

function Get-SPAccessServicesDatabaseServerGroupMapping
{
    # Mock stub for Get-SPAccessServicesDatabaseServerGroupMapping
}

function Get-SPAlternateURL
{
    # Mock stub for Get-SPAlternateURL
}

function Get-SPAppAcquisitionConfiguration
{
    # Mock stub for Get-SPAppAcquisitionConfiguration
}

function Get-SPAppAutoProvisionConnection
{
    # Mock stub for Get-SPAppAutoProvisionConnection
}

function Get-SPAppDeniedEndpointList
{
    # Mock stub for Get-SPAppDeniedEndpointList
}

function Get-SPAppDisablingConfiguration
{
    # Mock stub for Get-SPAppDisablingConfiguration
}

function Get-SPAppDomain
{
    # Mock stub for Get-SPAppDomain
}

function Get-SPAppHostingQuotaConfiguration
{
    # Mock stub for Get-SPAppHostingQuotaConfiguration
}

function Get-SPAppInstance
{
    # Mock stub for Get-SPAppInstance
}

function Get-SPAppPrincipal
{
    # Mock stub for Get-SPAppPrincipal
}

function Get-SPAppScaleProfile
{
    # Mock stub for Get-SPAppScaleProfile
}

function Get-SPAppSiteSubscriptionName
{
    # Mock stub for Get-SPAppSiteSubscriptionName
}

function Get-SPAppStateSyncLastRunTime
{
    # Mock stub for Get-SPAppStateSyncLastRunTime
}

function Get-SPAppStateUpdateInterval
{
    # Mock stub for Get-SPAppStateUpdateInterval
}

function Get-SPAppStoreConfiguration
{
    # Mock stub for Get-SPAppStoreConfiguration
}

function Get-SPAppStoreWebServiceConfiguration
{
    # Mock stub for Get-SPAppStoreWebServiceConfiguration
}

function Get-SPAuthenticationProvider
{
    # Mock stub for Get-SPAuthenticationProvider
}

function Get-SPAuthenticationRealm
{
    # Mock stub for Get-SPAuthenticationRealm
}

function Get-SPBackupHistory
{
    # Mock stub for Get-SPBackupHistory
}

function Get-SPBingMapsBlock
{
    # Mock stub for Get-SPBingMapsBlock
}

function Get-SPBingMapsKey
{
    # Mock stub for Get-SPBingMapsKey
}

function Get-SPBrowserCustomerExperienceImprovementProgram
{
    # Mock stub for Get-SPBrowserCustomerExperienceImprovementProgram
}

function Get-SPBusinessDataCatalogEntityNotificationWeb
{
    # Mock stub for Get-SPBusinessDataCatalogEntityNotificationWeb
}

function Get-SPBusinessDataCatalogMetadataObject
{
    # Mock stub for Get-SPBusinessDataCatalogMetadataObject
}

function Get-SPBusinessDataCatalogThrottleConfig
{
    # Mock stub for Get-SPBusinessDataCatalogThrottleConfig
}

function Get-SPCertificateAuthority
{
    # Mock stub for Get-SPCertificateAuthority
}

function Get-SPClaimProvider
{
    # Mock stub for Get-SPClaimProvider
}

function Get-SPClaimProviderManager
{
    # Mock stub for Get-SPClaimProviderManager
}

function Get-SPClaimTypeEncoding
{
    # Mock stub for Get-SPClaimTypeEncoding
}

function Get-SPConnectedServiceApplicationInformation
{
    # Mock stub for Get-SPConnectedServiceApplicationInformation
}

function Get-SPContentDatabase
{
    # Mock stub for Get-SPContentDatabase
}

function Get-SPContentDeploymentJob
{
    # Mock stub for Get-SPContentDeploymentJob
}

function Get-SPContentDeploymentPath
{
    # Mock stub for Get-SPContentDeploymentPath
}

function Get-SPCustomLayoutsPage
{
    # Mock stub for Get-SPCustomLayoutsPage
}

function Get-SPDatabase
{
    # Mock stub for Get-SPDatabase
}

function Get-SPDataConnectionFile
{
    # Mock stub for Get-SPDataConnectionFile
}

function Get-SPDataConnectionFileDependent
{
    # Mock stub for Get-SPDataConnectionFileDependent
}

function Get-SPDeletedSite
{
    # Mock stub for Get-SPDeletedSite
}

function Get-SPDesignerSettings
{
    # Mock stub for Get-SPDesignerSettings
}

function Get-SPDiagnosticConfig
{
    # Mock stub for Get-SPDiagnosticConfig
}

function Get-SPDiagnosticsPerformanceCounter
{
    # Mock stub for Get-SPDiagnosticsPerformanceCounter
}

function Get-SPDiagnosticsProvider
{
    # Mock stub for Get-SPDiagnosticsProvider
}

function Get-SPDistributedCacheClientSetting
{
    # Mock stub for Get-SPDistributedCacheClientSetting
}

function Get-SPEnterpriseSearchAdministrationComponent
{
    # Mock stub for Get-SPEnterpriseSearchAdministrationComponent
}

function Get-SPEnterpriseSearchComponent
{
    # Mock stub for Get-SPEnterpriseSearchComponent
}

function Get-SPEnterpriseSearchContentEnrichmentConfiguration
{
    # Mock stub for Get-SPEnterpriseSearchContentEnrichmentConfiguration
}

function Get-SPEnterpriseSearchCrawlContentSource
{
    # Mock stub for Get-SPEnterpriseSearchCrawlContentSource
}

function Get-SPEnterpriseSearchCrawlCustomConnector
{
    # Mock stub for Get-SPEnterpriseSearchCrawlCustomConnector
}

function Get-SPEnterpriseSearchCrawlDatabase
{
    # Mock stub for Get-SPEnterpriseSearchCrawlDatabase
}

function Get-SPEnterpriseSearchCrawlExtension
{
    # Mock stub for Get-SPEnterpriseSearchCrawlExtension
}

function Get-SPEnterpriseSearchCrawlLogReadPermission
{
    # Mock stub for Get-SPEnterpriseSearchCrawlLogReadPermission
}

function Get-SPEnterpriseSearchCrawlMapping
{
    # Mock stub for Get-SPEnterpriseSearchCrawlMapping
}

function Get-SPEnterpriseSearchCrawlRule
{
    # Mock stub for Get-SPEnterpriseSearchCrawlRule
}

function Get-SPEnterpriseSearchFileFormat
{
    # Mock stub for Get-SPEnterpriseSearchFileFormat
}

function Get-SPEnterpriseSearchHostController
{
    # Mock stub for Get-SPEnterpriseSearchHostController
}

function Get-SPEnterpriseSearchLanguageResourcePhrase
{
    # Mock stub for Get-SPEnterpriseSearchLanguageResourcePhrase
}

function Get-SPEnterpriseSearchLinguisticComponentsStatus
{
    # Mock stub for Get-SPEnterpriseSearchLinguisticComponentsStatus
}

function Get-SPEnterpriseSearchLinksDatabase
{
    # Mock stub for Get-SPEnterpriseSearchLinksDatabase
}

function Get-SPEnterpriseSearchMetadataCategory
{
    # Mock stub for Get-SPEnterpriseSearchMetadataCategory
}

function Get-SPEnterpriseSearchMetadataCrawledProperty
{
    # Mock stub for Get-SPEnterpriseSearchMetadataCrawledProperty
}

function Get-SPEnterpriseSearchMetadataManagedProperty
{
    # Mock stub for Get-SPEnterpriseSearchMetadataManagedProperty
}

function Get-SPEnterpriseSearchMetadataMapping
{
    # Mock stub for Get-SPEnterpriseSearchMetadataMapping
}

function Get-SPEnterpriseSearchOwner
{
    # Mock stub for Get-SPEnterpriseSearchOwner
}

function Get-SPEnterpriseSearchPropertyRule
{
    # Mock stub for Get-SPEnterpriseSearchPropertyRule
}

function Get-SPEnterpriseSearchPropertyRuleCollection
{
    # Mock stub for Get-SPEnterpriseSearchPropertyRuleCollection
}

function Get-SPEnterpriseSearchQueryAndSiteSettingsService
{
    # Mock stub for Get-SPEnterpriseSearchQueryAndSiteSettingsService
}

function Get-SPEnterpriseSearchQueryAndSiteSettingsServiceInstance
{
    # Mock stub for Get-SPEnterpriseSearchQueryAndSiteSettingsServiceInstance
}

function Get-SPEnterpriseSearchQueryAndSiteSettingsServiceProxy
{
    # Mock stub for Get-SPEnterpriseSearchQueryAndSiteSettingsServiceProxy
}

function Get-SPEnterpriseSearchQueryAuthority
{
    # Mock stub for Get-SPEnterpriseSearchQueryAuthority
}

function Get-SPEnterpriseSearchQueryDemoted
{
    # Mock stub for Get-SPEnterpriseSearchQueryDemoted
}

function Get-SPEnterpriseSearchQueryKeyword
{
    # Mock stub for Get-SPEnterpriseSearchQueryKeyword
}

function Get-SPEnterpriseSearchQueryScope
{
    # Mock stub for Get-SPEnterpriseSearchQueryScope
}

function Get-SPEnterpriseSearchQueryScopeRule
{
    # Mock stub for Get-SPEnterpriseSearchQueryScopeRule
}

function Get-SPEnterpriseSearchQuerySpellingCorrection
{
    # Mock stub for Get-SPEnterpriseSearchQuerySpellingCorrection
}

function Get-SPEnterpriseSearchQuerySuggestionCandidates
{
    # Mock stub for Get-SPEnterpriseSearchQuerySuggestionCandidates
}

function Get-SPEnterpriseSearchRankingModel
{
    # Mock stub for Get-SPEnterpriseSearchRankingModel
}

function Get-SPEnterpriseSearchResultItemType
{
    # Mock stub for Get-SPEnterpriseSearchResultItemType
}

function Get-SPEnterpriseSearchResultSource
{
    # Mock stub for Get-SPEnterpriseSearchResultSource
}

function Get-SPEnterpriseSearchSecurityTrimmer
{
    # Mock stub for Get-SPEnterpriseSearchSecurityTrimmer
}

function Get-SPEnterpriseSearchService
{
    # Mock stub for Get-SPEnterpriseSearchService
}

function Get-SPEnterpriseSearchServiceApplication
{
    # Mock stub for Get-SPEnterpriseSearchServiceApplication
}

function Get-SPEnterpriseSearchServiceApplicationBackupStore
{
    # Mock stub for Get-SPEnterpriseSearchServiceApplicationBackupStore
}

function Get-SPEnterpriseSearchServiceApplicationProxy
{
    # Mock stub for Get-SPEnterpriseSearchServiceApplicationProxy
}

function Get-SPEnterpriseSearchServiceInstance
{
    # Mock stub for Get-SPEnterpriseSearchServiceInstance
}

function Get-SPEnterpriseSearchSiteHitRule
{
    # Mock stub for Get-SPEnterpriseSearchSiteHitRule
}

function Get-SPEnterpriseSearchStatus
{
    # Mock stub for Get-SPEnterpriseSearchStatus
}

function Get-SPEnterpriseSearchTopology
{
    # Mock stub for Get-SPEnterpriseSearchTopology
}

function Get-SPEnterpriseSearchVssDataPath
{
    # Mock stub for Get-SPEnterpriseSearchVssDataPath
}

function Get-SPFarm
{
    # Mock stub for Get-SPFarm
}

function Get-SPFarmConfig
{
    # Mock stub for Get-SPFarmConfig
}

function Get-SPFeature
{
    # Mock stub for Get-SPFeature
}

function Get-SPHealthAnalysisRule
{
    # Mock stub for Get-SPHealthAnalysisRule
}

function Get-SPHelpCollection
{
    # Mock stub for Get-SPHelpCollection
}

function Get-SPInfoPathFormsService
{
    # Mock stub for Get-SPInfoPathFormsService
}

function Get-SPInfoPathFormTemplate
{
    # Mock stub for Get-SPInfoPathFormTemplate
}

function Get-SPInfoPathUserAgent
{
    # Mock stub for Get-SPInfoPathUserAgent
}

function Get-SPInfoPathWebServiceProxy
{
    # Mock stub for Get-SPInfoPathWebServiceProxy
}

function Get-SPInsightsConfig
{
    # Mock stub for Get-SPInsightsConfig
}

function Get-SPInternalAppStateSyncLastRunTime
{
    # Mock stub for Get-SPInternalAppStateSyncLastRunTime
}

function Get-SPInternalAppStateUpdateInterval
{
    # Mock stub for Get-SPInternalAppStateUpdateInterval
}

function Get-SPIRMSettings
{
    # Mock stub for Get-SPIRMSettings
}

function Get-SPLogEvent
{
    # Mock stub for Get-SPLogEvent
}

function Get-SPLogLevel
{
    # Mock stub for Get-SPLogLevel
}

function Get-SPManagedAccount
{
    # Mock stub for Get-SPManagedAccount
}

function Get-SPManagedPath
{
    # Mock stub for Get-SPManagedPath
}

function Get-SPMetadataServiceApplication
{
    # Mock stub for Get-SPMetadataServiceApplication
}

function Get-SPMetadataServiceApplicationProxy
{
    # Mock stub for Get-SPMetadataServiceApplicationProxy
}

function Get-SPMicrofeedOptions
{
    # Mock stub for Get-SPMicrofeedOptions
}

function Get-SPMobileMessagingAccount
{
    # Mock stub for Get-SPMobileMessagingAccount
}

function Get-SPO365LinkSettings
{
    # Mock stub for Get-SPO365LinkSettings
}

function Get-SPODataConnectionSetting
{
    # Mock stub for Get-SPODataConnectionSetting
}

function Get-SPODataConnectionSettingMetadata
{
    # Mock stub for Get-SPODataConnectionSettingMetadata
}

function Get-SPOfficeStoreAppsDefaultActivation
{
    # Mock stub for Get-SPOfficeStoreAppsDefaultActivation
}

function Get-SPPendingUpgradeActions
{
    # Mock stub for Get-SPPendingUpgradeActions
}

function Get-SPPerformancePointServiceApplication
{
    # Mock stub for Get-SPPerformancePointServiceApplication
}

function Get-SPPerformancePointServiceApplicationTrustedLocation
{
    # Mock stub for Get-SPPerformancePointServiceApplicationTrustedLocation
}

function Get-SPPluggableSecurityTrimmer
{
    # Mock stub for Get-SPPluggableSecurityTrimmer
}

function Get-SPProcessAccount
{
    # Mock stub for Get-SPProcessAccount
}

function Get-SPProduct
{
    # Mock stub for Get-SPProduct
}

function Get-SPProfileLeader
{
    # Mock stub for Get-SPProfileLeader
}

function Get-SPProfileServiceApplicationSecurity
{
    # Mock stub for Get-SPProfileServiceApplicationSecurity
}

function Get-SPProjectDatabaseQuota
{
    # Mock stub for Get-SPProjectDatabaseQuota
}

function Get-SPProjectDatabaseUsage
{
    # Mock stub for Get-SPProjectDatabaseUsage
}

function Get-SPProjectEnterpriseProjectTaskSync
{
    # Mock stub for Get-SPProjectEnterpriseProjectTaskSync
}

function Get-SPProjectEventServiceSettings
{
    # Mock stub for Get-SPProjectEventServiceSettings
}

function Get-SPProjectIsEmailNotificationEnabled
{
    # Mock stub for Get-SPProjectIsEmailNotificationEnabled
}

function Get-SPProjectOdataConfiguration
{
    # Mock stub for Get-SPProjectOdataConfiguration
}

function Get-SPProjectPCSSettings
{
    # Mock stub for Get-SPProjectPCSSettings
}

function Get-SPProjectPermissionMode
{
    # Mock stub for Get-SPProjectPermissionMode
}

function Get-SPProjectQueueSettings
{
    # Mock stub for Get-SPProjectQueueSettings
}

function Get-SPProjectWebInstance
{
    # Mock stub for Get-SPProjectWebInstance
}

function Get-SPRequestManagementSettings
{
    # Mock stub for Get-SPRequestManagementSettings
}

function Get-SPRoutingMachineInfo
{
    # Mock stub for Get-SPRoutingMachineInfo
}

function Get-SPRoutingMachinePool
{
    # Mock stub for Get-SPRoutingMachinePool
}

function Get-SPRoutingRule
{
    # Mock stub for Get-SPRoutingRule
}

function Get-SPScaleOutDatabase
{
    # Mock stub for Get-SPScaleOutDatabase
}

function Get-SPScaleOutDatabaseDataState
{
    # Mock stub for Get-SPScaleOutDatabaseDataState
}

function Get-SPScaleOutDatabaseInconsistency
{
    # Mock stub for Get-SPScaleOutDatabaseInconsistency
}

function Get-SPScaleOutDatabaseLogEntry
{
    # Mock stub for Get-SPScaleOutDatabaseLogEntry
}

function Get-SPSecureStoreApplication
{
    # Mock stub for Get-SPSecureStoreApplication
}

function Get-SPSecureStoreSystemAccount
{
    # Mock stub for Get-SPSecureStoreSystemAccount
}

function Get-SPSecurityTokenServiceConfig
{
    # Mock stub for Get-SPSecurityTokenServiceConfig
}

function Get-SPServer
{
    # Mock stub for Get-SPServer
}

function Get-SPServerScaleOutDatabase
{
    # Mock stub for Get-SPServerScaleOutDatabase
}

function Get-SPServerScaleOutDatabaseDataState
{
    # Mock stub for Get-SPServerScaleOutDatabaseDataState
}

function Get-SPServerScaleOutDatabaseInconsistency
{
    # Mock stub for Get-SPServerScaleOutDatabaseInconsistency
}

function Get-SPServerScaleOutDatabaseLogEntry
{
    # Mock stub for Get-SPServerScaleOutDatabaseLogEntry
}

function Get-SPService
{
    # Mock stub for Get-SPService
}

function Get-SPServiceApplication
{
    # Mock stub for Get-SPServiceApplication
}

function Get-SPServiceApplicationEndpoint
{
    # Mock stub for Get-SPServiceApplicationEndpoint
}

function Get-SPServiceApplicationPool
{
    # Mock stub for Get-SPServiceApplicationPool
}

function Get-SPServiceApplicationProxy
{
    # Mock stub for Get-SPServiceApplicationProxy
}

function Get-SPServiceApplicationProxyGroup
{
    # Mock stub for Get-SPServiceApplicationProxyGroup
}

function Get-SPServiceApplicationSecurity
{
    # Mock stub for Get-SPServiceApplicationSecurity
}

function Get-SPServiceContext
{
    # Mock stub for Get-SPServiceContext
}

function Get-SPServiceHostConfig
{
    # Mock stub for Get-SPServiceHostConfig
}

function Get-SPServiceInstance
{
    # Mock stub for Get-SPServiceInstance
}

function Get-SPSessionStateService
{
    # Mock stub for Get-SPSessionStateService
}

function Get-SPShellAdmin
{
    # Mock stub for Get-SPShellAdmin
}

function Get-SPSite
{
    # Mock stub for Get-SPSite
}

function Get-SPSiteAdministration
{
    # Mock stub for Get-SPSiteAdministration
}

function Get-SPSiteMapDatabase
{
    # Mock stub for Get-SPSiteMapDatabase
}

function Get-SPSiteMaster
{
    # Mock stub for Get-SPSiteMaster
}

function Get-SPSiteSubscription
{
    # Mock stub for Get-SPSiteSubscription
}

function Get-SPSiteSubscriptionConfig
{
    # Mock stub for Get-SPSiteSubscriptionConfig
}

function Get-SPSiteSubscriptionEdiscoveryHub
{
    # Mock stub for Get-SPSiteSubscriptionEdiscoveryHub
}

function Get-SPSiteSubscriptionEdiscoverySearchScope
{
    # Mock stub for Get-SPSiteSubscriptionEdiscoverySearchScope
}

function Get-SPSiteSubscriptionFeaturePack
{
    # Mock stub for Get-SPSiteSubscriptionFeaturePack
}

function Get-SPSiteSubscriptionIRMConfig
{
    # Mock stub for Get-SPSiteSubscriptionIRMConfig
}

function Get-SPSiteSubscriptionMetadataConfig
{
    # Mock stub for Get-SPSiteSubscriptionMetadataConfig
}

function Get-SPSiteUpgradeSessionInfo
{
    # Mock stub for Get-SPSiteUpgradeSessionInfo
}

function Get-SPSiteURL
{
    # Mock stub for Get-SPSiteURL
}

function Get-SPSolution
{
    # Mock stub for Get-SPSolution
}

function Get-SPStateServiceApplication
{
    # Mock stub for Get-SPStateServiceApplication
}

function Get-SPStateServiceApplicationProxy
{
    # Mock stub for Get-SPStateServiceApplicationProxy
}

function Get-SPStateServiceDatabase
{
    # Mock stub for Get-SPStateServiceDatabase
}

function Get-SPTaxonomySession
{
    # Mock stub for Get-SPTaxonomySession
}

function Get-SPThrottlingRule
{
    # Mock stub for Get-SPThrottlingRule
}

function Get-SPTimerJob
{
    # Mock stub for Get-SPTimerJob
}

function Get-SPTopologyServiceApplication
{
    # Mock stub for Get-SPTopologyServiceApplication
}

function Get-SPTopologyServiceApplicationProxy
{
    # Mock stub for Get-SPTopologyServiceApplicationProxy
}

function Get-SPTranslationThrottlingSetting
{
    # Mock stub for Get-SPTranslationThrottlingSetting
}

function Get-SPTrustedIdentityTokenIssuer
{
    # Mock stub for Get-SPTrustedIdentityTokenIssuer
}

function Get-SPTrustedRootAuthority
{
    # Mock stub for Get-SPTrustedRootAuthority
}

function Get-SPTrustedSecurityTokenIssuer
{
    # Mock stub for Get-SPTrustedSecurityTokenIssuer
}

function Get-SPTrustedServiceTokenIssuer
{
    # Mock stub for Get-SPTrustedServiceTokenIssuer
}

function Get-SPUpgradeActions
{
    # Mock stub for Get-SPUpgradeActions
}

function Get-SPUsageApplication
{
    # Mock stub for Get-SPUsageApplication
}

function Get-SPUsageDefinition
{
    # Mock stub for Get-SPUsageDefinition
}

function Get-SPUsageService
{
    # Mock stub for Get-SPUsageService
}

function Get-SPUser
{
    # Mock stub for Get-SPUser
}

function Get-SPUserLicense
{
    # Mock stub for Get-SPUserLicense
}

function Get-SPUserLicenseMapping
{
    # Mock stub for Get-SPUserLicenseMapping
}

function Get-SPUserLicensing
{
    # Mock stub for Get-SPUserLicensing
}

function Get-SPUserSettingsProvider
{
    # Mock stub for Get-SPUserSettingsProvider
}

function Get-SPUserSettingsProviderManager
{
    # Mock stub for Get-SPUserSettingsProviderManager
}

function Get-SPUserSolution
{
    # Mock stub for Get-SPUserSolution
}

function Get-SPUserSolutionAllowList
{
    # Mock stub for Get-SPUserSolutionAllowList
}

function Get-SPVisioExternalData
{
    # Mock stub for Get-SPVisioExternalData
}

function Get-SPVisioPerformance
{
    # Mock stub for Get-SPVisioPerformance
}

function Get-SPVisioSafeDataProvider
{
    # Mock stub for Get-SPVisioSafeDataProvider
}

function Get-SPVisioServiceApplication
{
    # Mock stub for Get-SPVisioServiceApplication
}

function Get-SPVisioServiceApplicationProxy
{
    # Mock stub for Get-SPVisioServiceApplicationProxy
}

function Get-SPWeb
{
    # Mock stub for Get-SPWeb
}

function Get-SPWebApplication
{
    # Mock stub for Get-SPWebApplication
}

function Get-SPWebApplicationAppDomain
{
    # Mock stub for Get-SPWebApplicationAppDomain
}

function Get-SPWebApplicationHttpThrottlingMonitor
{
    # Mock stub for Get-SPWebApplicationHttpThrottlingMonitor
}

function Get-SPWebPartPack
{
    # Mock stub for Get-SPWebPartPack
}

function Get-SPWebTemplate
{
    # Mock stub for Get-SPWebTemplate
}

function Get-SPWebTemplatesEnabledForSiteMaster
{
    # Mock stub for Get-SPWebTemplatesEnabledForSiteMaster
}

function Get-SPWOPIBinding
{
    # Mock stub for Get-SPWOPIBinding
}

function Get-SPWOPISuppressionSetting
{
    # Mock stub for Get-SPWOPISuppressionSetting
}

function Get-SPWOPIZone
{
    # Mock stub for Get-SPWOPIZone
}

function Get-SPWorkflowConfig
{
    # Mock stub for Get-SPWorkflowConfig
}

function Get-SPWorkflowServiceApplicationProxy
{
    # Mock stub for Get-SPWorkflowServiceApplicationProxy
}

function Grant-SPBusinessDataCatalogMetadataObject
{
    # Mock stub for Grant-SPBusinessDataCatalogMetadataObject
}

function Grant-SPObjectSecurity
{
    # Mock stub for Grant-SPObjectSecurity
}

function Import-SPAccessServicesDatabase
{
    # Mock stub for Import-SPAccessServicesDatabase
}

function Import-SPAppPackage
{
    # Mock stub for Import-SPAppPackage
}

function Import-SPBusinessDataCatalogDotNetAssembly
{
    # Mock stub for Import-SPBusinessDataCatalogDotNetAssembly
}

function Import-SPBusinessDataCatalogModel
{
    # Mock stub for Import-SPBusinessDataCatalogModel
}

function Import-SPEnterpriseSearchCustomExtractionDictionary
{
    # Mock stub for Import-SPEnterpriseSearchCustomExtractionDictionary
}

function Import-SPEnterpriseSearchPopularQueries
{
    # Mock stub for Import-SPEnterpriseSearchPopularQueries
}

function Import-SPEnterpriseSearchThesaurus
{
    # Mock stub for Import-SPEnterpriseSearchThesaurus
}

function Import-SPEnterpriseSearchTopology
{
    # Mock stub for Import-SPEnterpriseSearchTopology
}

function Import-SPInfoPathAdministrationFiles
{
    # Mock stub for Import-SPInfoPathAdministrationFiles
}

function Import-SPMetadataWebServicePartitionData
{
    # Mock stub for Import-SPMetadataWebServicePartitionData
}

function Import-SPPerformancePointContent
{
    # Mock stub for Import-SPPerformancePointContent
}

function Import-SPScaleOutDatabaseTenantData
{
    # Mock stub for Import-SPScaleOutDatabaseTenantData
}

function Import-SPServerScaleOutDatabaseTenantData
{
    # Mock stub for Import-SPServerScaleOutDatabaseTenantData
}

function Import-SPSiteSubscriptionBusinessDataCatalogConfig
{
    # Mock stub for Import-SPSiteSubscriptionBusinessDataCatalogConfig
}

function Import-SPSiteSubscriptionSettings
{
    # Mock stub for Import-SPSiteSubscriptionSettings
}

function Import-SPWeb
{
    # Mock stub for Import-SPWeb
}

function Initialize-SPResourceSecurity
{
    # Mock stub for Initialize-SPResourceSecurity
}

function Initialize-SPStateServiceDatabase
{
    # Mock stub for Initialize-SPStateServiceDatabase
}

function Install-SPApp
{
    # Mock stub for Install-SPApp
}

function Install-SPApplicationContent
{
    # Mock stub for Install-SPApplicationContent
}

function Install-SPDataConnectionFile
{
    # Mock stub for Install-SPDataConnectionFile
}

function Install-SPFeature
{
    # Mock stub for Install-SPFeature
}

function Install-SPHelpCollection
{
    # Mock stub for Install-SPHelpCollection
}

function Install-SPInfoPathFormTemplate
{
    # Mock stub for Install-SPInfoPathFormTemplate
}

function Install-SPService
{
    # Mock stub for Install-SPService
}

function Install-SPSolution
{
    # Mock stub for Install-SPSolution
}

function Install-SPUserSolution
{
    # Mock stub for Install-SPUserSolution
}

function Install-SPWebPartPack
{
    # Mock stub for Install-SPWebPartPack
}

function Invoke-SPProjectActiveDirectoryEnterpriseResourcePoolSync
{
    # Mock stub for Invoke-SPProjectActiveDirectoryEnterpriseResourcePoolSync
}

function Invoke-SPProjectActiveDirectoryGroupSync
{
    # Mock stub for Invoke-SPProjectActiveDirectoryGroupSync
}

function Merge-SPLogFile
{
    # Mock stub for Merge-SPLogFile
}

function Merge-SPUsageLog
{
    # Mock stub for Merge-SPUsageLog
}

function Migrate-SPDatabase
{
    # Mock stub for Migrate-SPDatabase
}

function Migrate-SPProjectDatabase
{
    # Mock stub for Migrate-SPProjectDatabase
}

function Migrate-SPProjectResourcePlans
{
    # Mock stub for Migrate-SPProjectResourcePlans
}

function Mount-SPContentDatabase
{
    # Mock stub for Mount-SPContentDatabase
}

function Mount-SPSiteMapDatabase
{
    # Mock stub for Mount-SPSiteMapDatabase
}

function Mount-SPStateServiceDatabase
{
    # Mock stub for Mount-SPStateServiceDatabase
}

function Move-SPAppManagementData
{
    # Mock stub for Move-SPAppManagementData
}

function Move-SPBlobStorageLocation
{
    # Mock stub for Move-SPBlobStorageLocation
}

function Move-SPDeletedSite
{
    # Mock stub for Move-SPDeletedSite
}

function Move-SPEnterpriseSearchLinksDatabases
{
    # Mock stub for Move-SPEnterpriseSearchLinksDatabases
}

function Move-SPProfileManagedMetadataProperty
{
    # Mock stub for Move-SPProfileManagedMetadataProperty
}

function Move-SPSite
{
    # Mock stub for Move-SPSite
}

function Move-SPSocialComment
{
    # Mock stub for Move-SPSocialComment
}

function Move-SPUser
{
    # Mock stub for Move-SPUser
}

function New-SPAccessServiceApplication
{
    # Mock stub for New-SPAccessServiceApplication
}

function New-SPAccessServicesApplication
{
    # Mock stub for New-SPAccessServicesApplication
}

function New-SPAccessServicesApplicationProxy
{
    # Mock stub for New-SPAccessServicesApplicationProxy
}

function New-SPAccessServicesDatabaseServer
{
    # Mock stub for New-SPAccessServicesDatabaseServer
}

function New-SPAlternateURL
{
    # Mock stub for New-SPAlternateURL
}

function New-SPAppManagementServiceApplication
{
    # Mock stub for New-SPAppManagementServiceApplication
}

function New-SPAppManagementServiceApplicationProxy
{
    # Mock stub for New-SPAppManagementServiceApplicationProxy
}

function New-SPAuthenticationProvider
{
    # Mock stub for New-SPAuthenticationProvider
}

function New-SPAzureAccessControlServiceApplicationProxy
{
    # Mock stub for New-SPAzureAccessControlServiceApplicationProxy
}

function New-SPBECWebServiceApplicationProxy
{
    # Mock stub for New-SPBECWebServiceApplicationProxy
}

function New-SPBusinessDataCatalogServiceApplication
{
    # Mock stub for New-SPBusinessDataCatalogServiceApplication
}

function New-SPBusinessDataCatalogServiceApplicationProxy
{
    # Mock stub for New-SPBusinessDataCatalogServiceApplicationProxy
}

function New-SPCentralAdministration
{
    # Mock stub for New-SPCentralAdministration
}

function New-SPClaimProvider
{
    # Mock stub for New-SPClaimProvider
}

function New-SPClaimsPrincipal
{
    # Mock stub for New-SPClaimsPrincipal
}

function New-SPClaimTypeEncoding
{
    # Mock stub for New-SPClaimTypeEncoding
}

function New-SPClaimTypeMapping
{
    # Mock stub for New-SPClaimTypeMapping
}

function New-SPConfigurationDatabase
{
    # Mock stub for New-SPConfigurationDatabase
}

function New-SPContentDatabase
{
    # Mock stub for New-SPContentDatabase
}

function New-SPContentDeploymentJob
{
    # Mock stub for New-SPContentDeploymentJob
}

function New-SPContentDeploymentPath
{
    # Mock stub for New-SPContentDeploymentPath
}

function New-SPEnterpriseSearchAdminComponent
{
    # Mock stub for New-SPEnterpriseSearchAdminComponent
}

function New-SPEnterpriseSearchAnalyticsProcessingComponent
{
    # Mock stub for New-SPEnterpriseSearchAnalyticsProcessingComponent
}

function New-SPEnterpriseSearchContentEnrichmentConfiguration
{
    # Mock stub for New-SPEnterpriseSearchContentEnrichmentConfiguration
}

function New-SPEnterpriseSearchContentProcessingComponent
{
    # Mock stub for New-SPEnterpriseSearchContentProcessingComponent
}

function New-SPEnterpriseSearchCrawlComponent
{
    # Mock stub for New-SPEnterpriseSearchCrawlComponent
}

function New-SPEnterpriseSearchCrawlContentSource
{
    # Mock stub for New-SPEnterpriseSearchCrawlContentSource
}

function New-SPEnterpriseSearchCrawlCustomConnector
{
    # Mock stub for New-SPEnterpriseSearchCrawlCustomConnector
}

function New-SPEnterpriseSearchCrawlDatabase
{
    # Mock stub for New-SPEnterpriseSearchCrawlDatabase
}

function New-SPEnterpriseSearchCrawlExtension
{
    # Mock stub for New-SPEnterpriseSearchCrawlExtension
}

function New-SPEnterpriseSearchCrawlMapping
{
    # Mock stub for New-SPEnterpriseSearchCrawlMapping
}

function New-SPEnterpriseSearchCrawlRule
{
    # Mock stub for New-SPEnterpriseSearchCrawlRule
}

function New-SPEnterpriseSearchFileFormat
{
    # Mock stub for New-SPEnterpriseSearchFileFormat
}

function New-SPEnterpriseSearchIndexComponent
{
    # Mock stub for New-SPEnterpriseSearchIndexComponent
}

function New-SPEnterpriseSearchLanguageResourcePhrase
{
    # Mock stub for New-SPEnterpriseSearchLanguageResourcePhrase
}

function New-SPEnterpriseSearchLinksDatabase
{
    # Mock stub for New-SPEnterpriseSearchLinksDatabase
}

function New-SPEnterpriseSearchMetadataCategory
{
    # Mock stub for New-SPEnterpriseSearchMetadataCategory
}

function New-SPEnterpriseSearchMetadataCrawledProperty
{
    # Mock stub for New-SPEnterpriseSearchMetadataCrawledProperty
}

function New-SPEnterpriseSearchMetadataManagedProperty
{
    # Mock stub for New-SPEnterpriseSearchMetadataManagedProperty
}

function New-SPEnterpriseSearchMetadataMapping
{
    # Mock stub for New-SPEnterpriseSearchMetadataMapping
}

function New-SPEnterpriseSearchQueryAuthority
{
    # Mock stub for New-SPEnterpriseSearchQueryAuthority
}

function New-SPEnterpriseSearchQueryDemoted
{
    # Mock stub for New-SPEnterpriseSearchQueryDemoted
}

function New-SPEnterpriseSearchQueryKeyword
{
    # Mock stub for New-SPEnterpriseSearchQueryKeyword
}

function New-SPEnterpriseSearchQueryProcessingComponent
{
    # Mock stub for New-SPEnterpriseSearchQueryProcessingComponent
}

function New-SPEnterpriseSearchQueryScope
{
    # Mock stub for New-SPEnterpriseSearchQueryScope
}

function New-SPEnterpriseSearchQueryScopeRule
{
    # Mock stub for New-SPEnterpriseSearchQueryScopeRule
}

function New-SPEnterpriseSearchRankingModel
{
    # Mock stub for New-SPEnterpriseSearchRankingModel
}

function New-SPEnterpriseSearchResultItemType
{
    # Mock stub for New-SPEnterpriseSearchResultItemType
}

function New-SPEnterpriseSearchResultSource
{
    # Mock stub for New-SPEnterpriseSearchResultSource
}

function New-SPEnterpriseSearchSecurityTrimmer
{
    # Mock stub for New-SPEnterpriseSearchSecurityTrimmer
}

function New-SPEnterpriseSearchServiceApplication
{
    # Mock stub for New-SPEnterpriseSearchServiceApplication
}

function New-SPEnterpriseSearchServiceApplicationProxy
{
    # Mock stub for New-SPEnterpriseSearchServiceApplicationProxy
}

function New-SPEnterpriseSearchSiteHitRule
{
    # Mock stub for New-SPEnterpriseSearchSiteHitRule
}

function New-SPEnterpriseSearchTopology
{
    # Mock stub for New-SPEnterpriseSearchTopology
}

function New-SPLogFile
{
    # Mock stub for New-SPLogFile
}

function New-SPManagedAccount
{
    # Mock stub for New-SPManagedAccount
}

function New-SPManagedPath
{
    # Mock stub for New-SPManagedPath
}

function New-SPMarketplaceWebServiceApplicationProxy
{
    # Mock stub for New-SPMarketplaceWebServiceApplicationProxy
}

function New-SPMetadataServiceApplication
{
    # Mock stub for New-SPMetadataServiceApplication
}

function New-SPMetadataServiceApplicationProxy
{
    # Mock stub for New-SPMetadataServiceApplicationProxy
}

function New-SPODataConnectionSetting
{
    # Mock stub for New-SPODataConnectionSetting
}

function New-SPOnlineApplicationPrincipalManagementServiceApplicationProxy
{
    # Mock stub for New-SPOnlineApplicationPrincipalManagementServiceApplicationProxy
}

function New-SPPerformancePointServiceApplication
{
    # Mock stub for New-SPPerformancePointServiceApplication
}

function New-SPPerformancePointServiceApplicationProxy
{
    # Mock stub for New-SPPerformancePointServiceApplicationProxy
}

function New-SPPerformancePointServiceApplicationTrustedLocation
{
    # Mock stub for New-SPPerformancePointServiceApplicationTrustedLocation
}

function New-SPPowerPointConversionServiceApplication
{
    # Mock stub for New-SPPowerPointConversionServiceApplication
}

function New-SPPowerPointConversionServiceApplicationProxy
{
    # Mock stub for New-SPPowerPointConversionServiceApplicationProxy
}

function New-SPProfileServiceApplication
{
    # Mock stub for New-SPProfileServiceApplication
}

function New-SPProfileServiceApplicationProxy
{
    # Mock stub for New-SPProfileServiceApplicationProxy
}

function New-SPProjectServiceApplication
{
    # Mock stub for New-SPProjectServiceApplication
}

function New-SPProjectServiceApplicationProxy
{
    # Mock stub for New-SPProjectServiceApplicationProxy
}

function New-SPRequestManagementRuleCriteria
{
    # Mock stub for New-SPRequestManagementRuleCriteria
}

function New-SPSecureStoreApplication
{
    # Mock stub for New-SPSecureStoreApplication
}

function New-SPSecureStoreApplicationField
{
    # Mock stub for New-SPSecureStoreApplicationField
}

function New-SPSecureStoreServiceApplication
{
    # Mock stub for New-SPSecureStoreServiceApplication
}

function New-SPSecureStoreServiceApplicationProxy
{
    # Mock stub for New-SPSecureStoreServiceApplicationProxy
}

function New-SPSecureStoreTargetApplication
{
    # Mock stub for New-SPSecureStoreTargetApplication
}

function New-SPServiceApplicationPool
{
    # Mock stub for New-SPServiceApplicationPool
}

function New-SPServiceApplicationProxyGroup
{
    # Mock stub for New-SPServiceApplicationProxyGroup
}

function New-SPSite
{
    # Mock stub for New-SPSite
}

function New-SPSiteMaster
{
    # Mock stub for New-SPSiteMaster
}

function New-SPSiteSubscription
{
    # Mock stub for New-SPSiteSubscription
}

function New-SPSiteSubscriptionFeaturePack
{
    # Mock stub for New-SPSiteSubscriptionFeaturePack
}

function New-SPStateServiceApplication
{
    # Mock stub for New-SPStateServiceApplication
}

function New-SPStateServiceApplicationProxy
{
    # Mock stub for New-SPStateServiceApplicationProxy
}

function New-SPStateServiceDatabase
{
    # Mock stub for New-SPStateServiceDatabase
}

function New-SPSubscriptionSettingsServiceApplication
{
    # Mock stub for New-SPSubscriptionSettingsServiceApplication
}

function New-SPSubscriptionSettingsServiceApplicationProxy
{
    # Mock stub for New-SPSubscriptionSettingsServiceApplicationProxy
}

function New-SPTranslationServiceApplication
{
    # Mock stub for New-SPTranslationServiceApplication
}

function New-SPTranslationServiceApplicationProxy
{
    # Mock stub for New-SPTranslationServiceApplicationProxy
}

function New-SPTrustedIdentityTokenIssuer
{
    # Mock stub for New-SPTrustedIdentityTokenIssuer
}

function New-SPTrustedRootAuthority
{
    # Mock stub for New-SPTrustedRootAuthority
}

function New-SPTrustedSecurityTokenIssuer
{
    # Mock stub for New-SPTrustedSecurityTokenIssuer
}

function New-SPTrustedServiceTokenIssuer
{
    # Mock stub for New-SPTrustedServiceTokenIssuer
}

function New-SPUsageApplication
{
    # Mock stub for New-SPUsageApplication
}

function New-SPUsageLogFile
{
    # Mock stub for New-SPUsageLogFile
}

function New-SPUser
{
    # Mock stub for New-SPUser
}

function New-SPUserLicenseMapping
{
    # Mock stub for New-SPUserLicenseMapping
}

function New-SPUserSettingsProvider
{
    # Mock stub for New-SPUserSettingsProvider
}

function New-SPUserSolutionAllowList
{
    # Mock stub for New-SPUserSolutionAllowList
}

function New-SPVisioSafeDataProvider
{
    # Mock stub for New-SPVisioSafeDataProvider
}

function New-SPVisioServiceApplication
{
    # Mock stub for New-SPVisioServiceApplication
}

function New-SPVisioServiceApplicationProxy
{
    # Mock stub for New-SPVisioServiceApplicationProxy
}

function New-SPWeb
{
    # Mock stub for New-SPWeb
}

function New-SPWebApplication
{
    # Mock stub for New-SPWebApplication
}

function New-SPWebApplicationAppDomain
{
    # Mock stub for New-SPWebApplicationAppDomain
}

function New-SPWebApplicationExtension
{
    # Mock stub for New-SPWebApplicationExtension
}

function New-SPWOPIBinding
{
    # Mock stub for New-SPWOPIBinding
}

function New-SPWOPISuppressionSetting
{
    # Mock stub for New-SPWOPISuppressionSetting
}

function New-SPWordConversionServiceApplication
{
    # Mock stub for New-SPWordConversionServiceApplication
}

function New-SPWorkflowServiceApplicationProxy
{
    # Mock stub for New-SPWorkflowServiceApplicationProxy
}

function New-SPWorkManagementServiceApplication
{
    # Mock stub for New-SPWorkManagementServiceApplication
}

function New-SPWorkManagementServiceApplicationProxy
{
    # Mock stub for New-SPWorkManagementServiceApplicationProxy
}

function Pause-SPProjectWebInstance
{
    # Mock stub for Pause-SPProjectWebInstance
}

function Publish-SPServiceApplication
{
    # Mock stub for Publish-SPServiceApplication
}

function Receive-SPServiceApplicationConnectionInfo
{
    # Mock stub for Receive-SPServiceApplicationConnectionInfo
}

function Register-SPAppPrincipal
{
    # Mock stub for Register-SPAppPrincipal
}

function Register-SPWorkflowService
{
    # Mock stub for Register-SPWorkflowService
}

function Remove-DatabaseFromAvailabilityGroup
{
    # Mock stub for Remove-DatabaseFromAvailabilityGroup
}

function Remove-SPAccessServicesDatabaseServer
{
    # Mock stub for Remove-SPAccessServicesDatabaseServer
}

function Remove-SPActivityFeedItems
{
    # Mock stub for Remove-SPActivityFeedItems
}

function Remove-SPAlternateURL
{
    # Mock stub for Remove-SPAlternateURL
}

function Remove-SPAppDeniedEndpoint
{
    # Mock stub for Remove-SPAppDeniedEndpoint
}

function Remove-SPAppPrincipalPermission
{
    # Mock stub for Remove-SPAppPrincipalPermission
}

function Remove-SPBusinessDataCatalogModel
{
    # Mock stub for Remove-SPBusinessDataCatalogModel
}

function Remove-SPCentralAdministration
{
    # Mock stub for Remove-SPCentralAdministration
}

function Remove-SPClaimProvider
{
    # Mock stub for Remove-SPClaimProvider
}

function Remove-SPClaimTypeMapping
{
    # Mock stub for Remove-SPClaimTypeMapping
}

function Remove-SPConfigurationDatabase
{
    # Mock stub for Remove-SPConfigurationDatabase
}

function Remove-SPContentDatabase
{
    # Mock stub for Remove-SPContentDatabase
}

function Remove-SPContentDeploymentJob
{
    # Mock stub for Remove-SPContentDeploymentJob
}

function Remove-SPContentDeploymentPath
{
    # Mock stub for Remove-SPContentDeploymentPath
}

function Remove-SPDeletedSite
{
    # Mock stub for Remove-SPDeletedSite
}

function Remove-SPDiagnosticsPerformanceCounter
{
    # Mock stub for Remove-SPDiagnosticsPerformanceCounter
}

function Remove-SPDistributedCacheServiceInstance
{
    # Mock stub for Remove-SPDistributedCacheServiceInstance
}

function Remove-SPEnterpriseSearchComponent
{
    # Mock stub for Remove-SPEnterpriseSearchComponent
}

function Remove-SPEnterpriseSearchContentEnrichmentConfiguration
{
    # Mock stub for Remove-SPEnterpriseSearchContentEnrichmentConfiguration
}

function Remove-SPEnterpriseSearchCrawlContentSource
{
    # Mock stub for Remove-SPEnterpriseSearchCrawlContentSource
}

function Remove-SPEnterpriseSearchCrawlCustomConnector
{
    # Mock stub for Remove-SPEnterpriseSearchCrawlCustomConnector
}

function Remove-SPEnterpriseSearchCrawlDatabase
{
    # Mock stub for Remove-SPEnterpriseSearchCrawlDatabase
}

function Remove-SPEnterpriseSearchCrawlExtension
{
    # Mock stub for Remove-SPEnterpriseSearchCrawlExtension
}

function Remove-SPEnterpriseSearchCrawlLogReadPermission
{
    # Mock stub for Remove-SPEnterpriseSearchCrawlLogReadPermission
}

function Remove-SPEnterpriseSearchCrawlMapping
{
    # Mock stub for Remove-SPEnterpriseSearchCrawlMapping
}

function Remove-SPEnterpriseSearchCrawlRule
{
    # Mock stub for Remove-SPEnterpriseSearchCrawlRule
}

function Remove-SPEnterpriseSearchFileFormat
{
    # Mock stub for Remove-SPEnterpriseSearchFileFormat
}

function Remove-SPEnterpriseSearchLanguageResourcePhrase
{
    # Mock stub for Remove-SPEnterpriseSearchLanguageResourcePhrase
}

function Remove-SPEnterpriseSearchLinksDatabase
{
    # Mock stub for Remove-SPEnterpriseSearchLinksDatabase
}

function Remove-SPEnterpriseSearchMetadataCategory
{
    # Mock stub for Remove-SPEnterpriseSearchMetadataCategory
}

function Remove-SPEnterpriseSearchMetadataManagedProperty
{
    # Mock stub for Remove-SPEnterpriseSearchMetadataManagedProperty
}

function Remove-SPEnterpriseSearchMetadataMapping
{
    # Mock stub for Remove-SPEnterpriseSearchMetadataMapping
}

function Remove-SPEnterpriseSearchQueryAuthority
{
    # Mock stub for Remove-SPEnterpriseSearchQueryAuthority
}

function Remove-SPEnterpriseSearchQueryDemoted
{
    # Mock stub for Remove-SPEnterpriseSearchQueryDemoted
}

function Remove-SPEnterpriseSearchQueryKeyword
{
    # Mock stub for Remove-SPEnterpriseSearchQueryKeyword
}

function Remove-SPEnterpriseSearchQueryScope
{
    # Mock stub for Remove-SPEnterpriseSearchQueryScope
}

function Remove-SPEnterpriseSearchQueryScopeRule
{
    # Mock stub for Remove-SPEnterpriseSearchQueryScopeRule
}

function Remove-SPEnterpriseSearchRankingModel
{
    # Mock stub for Remove-SPEnterpriseSearchRankingModel
}

function Remove-SPEnterpriseSearchResultItemType
{
    # Mock stub for Remove-SPEnterpriseSearchResultItemType
}

function Remove-SPEnterpriseSearchResultSource
{
    # Mock stub for Remove-SPEnterpriseSearchResultSource
}

function Remove-SPEnterpriseSearchSecurityTrimmer
{
    # Mock stub for Remove-SPEnterpriseSearchSecurityTrimmer
}

function Remove-SPEnterpriseSearchServiceApplication
{
    # Mock stub for Remove-SPEnterpriseSearchServiceApplication
}

function Remove-SPEnterpriseSearchServiceApplicationProxy
{
    # Mock stub for Remove-SPEnterpriseSearchServiceApplicationProxy
}

function Remove-SPEnterpriseSearchServiceApplicationSiteSettings
{
    # Mock stub for Remove-SPEnterpriseSearchServiceApplicationSiteSettings
}

function Remove-SPEnterpriseSearchSiteHitRule
{
    # Mock stub for Remove-SPEnterpriseSearchSiteHitRule
}

function Remove-SPEnterpriseSearchTenantConfiguration
{
    # Mock stub for Remove-SPEnterpriseSearchTenantConfiguration
}

function Remove-SPEnterpriseSearchTenantSchema
{
    # Mock stub for Remove-SPEnterpriseSearchTenantSchema
}

function Remove-SPEnterpriseSearchTopology
{
    # Mock stub for Remove-SPEnterpriseSearchTopology
}

function Remove-SPInfoPathUserAgent
{
    # Mock stub for Remove-SPInfoPathUserAgent
}

function Remove-SPManagedAccount
{
    # Mock stub for Remove-SPManagedAccount
}

function Remove-SPManagedPath
{
    # Mock stub for Remove-SPManagedPath
}

function Remove-SPODataConnectionSetting
{
    # Mock stub for Remove-SPODataConnectionSetting
}

function Remove-SPPerformancePointServiceApplication
{
    # Mock stub for Remove-SPPerformancePointServiceApplication
}

function Remove-SPPerformancePointServiceApplicationProxy
{
    # Mock stub for Remove-SPPerformancePointServiceApplicationProxy
}

function Remove-SPPerformancePointServiceApplicationTrustedLocation
{
    # Mock stub for Remove-SPPerformancePointServiceApplicationTrustedLocation
}

function Remove-SPPluggableSecurityTrimmer
{
    # Mock stub for Remove-SPPluggableSecurityTrimmer
}

function Remove-SPProfileLeader
{
    # Mock stub for Remove-SPProfileLeader
}

function Remove-SPProfileSyncConnection
{
    # Mock stub for Remove-SPProfileSyncConnection
}

function Remove-SPProjectWebInstanceData
{
    # Mock stub for Remove-SPProjectWebInstanceData
}

function Remove-SPRoutingMachineInfo
{
    # Mock stub for Remove-SPRoutingMachineInfo
}

function Remove-SPRoutingMachinePool
{
    # Mock stub for Remove-SPRoutingMachinePool
}

function Remove-SPRoutingRule
{
    # Mock stub for Remove-SPRoutingRule
}

function Remove-SPScaleOutDatabase
{
    # Mock stub for Remove-SPScaleOutDatabase
}

function Remove-SPSecureStoreApplication
{
    # Mock stub for Remove-SPSecureStoreApplication
}

function Remove-SPSecureStoreSystemAccount
{
    # Mock stub for Remove-SPSecureStoreSystemAccount
}

function Remove-SPServerScaleOutDatabase
{
    # Mock stub for Remove-SPServerScaleOutDatabase
}

function Remove-SPServiceApplication
{
    # Mock stub for Remove-SPServiceApplication
}

function Remove-SPServiceApplicationPool
{
    # Mock stub for Remove-SPServiceApplicationPool
}

function Remove-SPServiceApplicationProxy
{
    # Mock stub for Remove-SPServiceApplicationProxy
}

function Remove-SPServiceApplicationProxyGroup
{
    # Mock stub for Remove-SPServiceApplicationProxyGroup
}

function Remove-SPServiceApplicationProxyGroupMember
{
    # Mock stub for Remove-SPServiceApplicationProxyGroupMember
}

function Remove-SPShellAdmin
{
    # Mock stub for Remove-SPShellAdmin
}

function Remove-SPSite
{
    # Mock stub for Remove-SPSite
}

function Remove-SPSiteMaster
{
    # Mock stub for Remove-SPSiteMaster
}

function Remove-SPSiteSubscription
{
    # Mock stub for Remove-SPSiteSubscription
}

function Remove-SPSiteSubscriptionBusinessDataCatalogConfig
{
    # Mock stub for Remove-SPSiteSubscriptionBusinessDataCatalogConfig
}

function Remove-SPSiteSubscriptionFeaturePack
{
    # Mock stub for Remove-SPSiteSubscriptionFeaturePack
}

function Remove-SPSiteSubscriptionFeaturePackMember
{
    # Mock stub for Remove-SPSiteSubscriptionFeaturePackMember
}

function Remove-SPSiteSubscriptionMetadataConfig
{
    # Mock stub for Remove-SPSiteSubscriptionMetadataConfig
}

function Remove-SPSiteSubscriptionProfileConfig
{
    # Mock stub for Remove-SPSiteSubscriptionProfileConfig
}

function Remove-SPSiteSubscriptionSettings
{
    # Mock stub for Remove-SPSiteSubscriptionSettings
}

function Remove-SPSiteUpgradeSessionInfo
{
    # Mock stub for Remove-SPSiteUpgradeSessionInfo
}

function Remove-SPSiteURL
{
    # Mock stub for Remove-SPSiteURL
}

function Remove-SPSocialItemByDate
{
    # Mock stub for Remove-SPSocialItemByDate
}

function Remove-SPSolution
{
    # Mock stub for Remove-SPSolution
}

function Remove-SPSolutionDeploymentLock
{
    # Mock stub for Remove-SPSolutionDeploymentLock
}

function Remove-SPStateServiceDatabase
{
    # Mock stub for Remove-SPStateServiceDatabase
}

function Remove-SPThrottlingRule
{
    # Mock stub for Remove-SPThrottlingRule
}

function Remove-SPTranslationServiceJobHistory
{
    # Mock stub for Remove-SPTranslationServiceJobHistory
}

function Remove-SPTrustedIdentityTokenIssuer
{
    # Mock stub for Remove-SPTrustedIdentityTokenIssuer
}

function Remove-SPTrustedRootAuthority
{
    # Mock stub for Remove-SPTrustedRootAuthority
}

function Remove-SPTrustedSecurityTokenIssuer
{
    # Mock stub for Remove-SPTrustedSecurityTokenIssuer
}

function Remove-SPTrustedServiceTokenIssuer
{
    # Mock stub for Remove-SPTrustedServiceTokenIssuer
}

function Remove-SPUsageApplication
{
    # Mock stub for Remove-SPUsageApplication
}

function Remove-SPUser
{
    # Mock stub for Remove-SPUser
}

function Remove-SPUserLicenseMapping
{
    # Mock stub for Remove-SPUserLicenseMapping
}

function Remove-SPUserSettingsProvider
{
    # Mock stub for Remove-SPUserSettingsProvider
}

function Remove-SPUserSolution
{
    # Mock stub for Remove-SPUserSolution
}

function Remove-SPVisioSafeDataProvider
{
    # Mock stub for Remove-SPVisioSafeDataProvider
}

function Remove-SPWeb
{
    # Mock stub for Remove-SPWeb
}

function Remove-SPWebApplication
{
    # Mock stub for Remove-SPWebApplication
}

function Remove-SPWebApplicationAppDomain
{
    # Mock stub for Remove-SPWebApplicationAppDomain
}

function Remove-SPWOPIBinding
{
    # Mock stub for Remove-SPWOPIBinding
}

function Remove-SPWOPISuppressionSetting
{
    # Mock stub for Remove-SPWOPISuppressionSetting
}

function Remove-SPWordConversionServiceJobHistory
{
    # Mock stub for Remove-SPWordConversionServiceJobHistory
}

function Rename-SPServer
{
    # Mock stub for Rename-SPServer
}

function Repair-SPManagedAccountDeployment
{
    # Mock stub for Repair-SPManagedAccountDeployment
}

function Repair-SPProjectWebInstance
{
    # Mock stub for Repair-SPProjectWebInstance
}

function Repair-SPSite
{
    # Mock stub for Repair-SPSite
}

function Request-SPUpgradeEvaluationSite
{
    # Mock stub for Request-SPUpgradeEvaluationSite
}

function Reset-SPAccessServicesDatabasePassword
{
    # Mock stub for Reset-SPAccessServicesDatabasePassword
}

function Reset-SPProjectEventServiceSettings
{
    # Mock stub for Reset-SPProjectEventServiceSettings
}

function Reset-SPProjectPCSSettings
{
    # Mock stub for Reset-SPProjectPCSSettings
}

function Reset-SPProjectQueueSettings
{
    # Mock stub for Reset-SPProjectQueueSettings
}

function Reset-SPSites
{
    # Mock stub for Reset-SPSites
}

function Restart-SPAppInstanceJob
{
    # Mock stub for Restart-SPAppInstanceJob
}

function Restore-SPDeletedSite
{
    # Mock stub for Restore-SPDeletedSite
}

function Restore-SPEnterpriseSearchServiceApplication
{
    # Mock stub for Restore-SPEnterpriseSearchServiceApplication
}

function Restore-SPEnterpriseSearchServiceApplicationIndex
{
    # Mock stub for Restore-SPEnterpriseSearchServiceApplicationIndex
}

function Restore-SPFarm
{
    # Mock stub for Restore-SPFarm
}

function Restore-SPSite
{
    # Mock stub for Restore-SPSite
}

function Resume-SPEnterpriseSearchServiceApplication
{
    # Mock stub for Resume-SPEnterpriseSearchServiceApplication
}

function Resume-SPProjectWebInstance
{
    # Mock stub for Resume-SPProjectWebInstance
}

function Resume-SPStateServiceDatabase
{
    # Mock stub for Resume-SPStateServiceDatabase
}

function Revoke-SPBusinessDataCatalogMetadataObject
{
    # Mock stub for Revoke-SPBusinessDataCatalogMetadataObject
}

function Revoke-SPObjectSecurity
{
    # Mock stub for Revoke-SPObjectSecurity
}

function Set-SPAccessServiceApplication
{
    # Mock stub for Set-SPAccessServiceApplication
}

function Set-SPAccessServicesApplication
{
    # Mock stub for Set-SPAccessServicesApplication
}

function Set-SPAccessServicesDatabaseServer
{
    # Mock stub for Set-SPAccessServicesDatabaseServer
}

function Set-SPAccessServicesDatabaseServerGroupMapping
{
    # Mock stub for Set-SPAccessServicesDatabaseServerGroupMapping
}

function Set-SPAlternateURL
{
    # Mock stub for Set-SPAlternateURL
}

function Set-SPAppAcquisitionConfiguration
{
    # Mock stub for Set-SPAppAcquisitionConfiguration
}

function Set-SPAppAutoProvisionConnection
{
    # Mock stub for Set-SPAppAutoProvisionConnection
}

function Set-SPAppDisablingConfiguration
{
    # Mock stub for Set-SPAppDisablingConfiguration
}

function Set-SPAppDomain
{
    # Mock stub for Set-SPAppDomain
}

function Set-SPAppHostingQuotaConfiguration
{
    # Mock stub for Set-SPAppHostingQuotaConfiguration
}

function Set-SPAppManagementDeploymentId
{
    # Mock stub for Set-SPAppManagementDeploymentId
}

function Set-SPAppPrincipalPermission
{
    # Mock stub for Set-SPAppPrincipalPermission
}

function Set-SPAppScaleProfile
{
    # Mock stub for Set-SPAppScaleProfile
}

function Set-SPAppSiteDomain
{
    # Mock stub for Set-SPAppSiteDomain
}

function Set-SPAppSiteSubscriptionName
{
    # Mock stub for Set-SPAppSiteSubscriptionName
}

function Set-SPAppStateUpdateInterval
{
    # Mock stub for Set-SPAppStateUpdateInterval
}

function Set-SPAppStoreConfiguration
{
    # Mock stub for Set-SPAppStoreConfiguration
}

function Set-SPAppStoreWebServiceConfiguration
{
    # Mock stub for Set-SPAppStoreWebServiceConfiguration
}

function Set-SPAuthenticationRealm
{
    # Mock stub for Set-SPAuthenticationRealm
}

function Set-SPBingMapsBlock
{
    # Mock stub for Set-SPBingMapsBlock
}

function Set-SPBingMapsKey
{
    # Mock stub for Set-SPBingMapsKey
}

function Set-SPBrowserCustomerExperienceImprovementProgram
{
    # Mock stub for Set-SPBrowserCustomerExperienceImprovementProgram
}

function Set-SPBusinessDataCatalogEntityNotificationWeb
{
    # Mock stub for Set-SPBusinessDataCatalogEntityNotificationWeb
}

function Set-SPBusinessDataCatalogMetadataObject
{
    # Mock stub for Set-SPBusinessDataCatalogMetadataObject
}

function Set-SPBusinessDataCatalogServiceApplication
{
    # Mock stub for Set-SPBusinessDataCatalogServiceApplication
}

function Set-SPBusinessDataCatalogThrottleConfig
{
    # Mock stub for Set-SPBusinessDataCatalogThrottleConfig
}

function Set-SPCentralAdministration
{
    # Mock stub for Set-SPCentralAdministration
}

function Set-SPClaimProvider
{
    # Mock stub for Set-SPClaimProvider
}

function Set-SPContentDatabase
{
    # Mock stub for Set-SPContentDatabase
}

function Set-SPContentDeploymentJob
{
    # Mock stub for Set-SPContentDeploymentJob
}

function Set-SPContentDeploymentPath
{
    # Mock stub for Set-SPContentDeploymentPath
}

function Set-SPCustomLayoutsPage
{
    # Mock stub for Set-SPCustomLayoutsPage
}

function Set-SPDataConnectionFile
{
    # Mock stub for Set-SPDataConnectionFile
}

function Set-SPDefaultProfileConfig
{
    # Mock stub for Set-SPDefaultProfileConfig
}

function Set-SPDesignerSettings
{
    # Mock stub for Set-SPDesignerSettings
}

function Set-SPDiagnosticConfig
{
    # Mock stub for Set-SPDiagnosticConfig
}

function Set-SPDiagnosticsProvider
{
    # Mock stub for Set-SPDiagnosticsProvider
}

function Set-SPDistributedCacheClientSetting
{
    # Mock stub for Set-SPDistributedCacheClientSetting
}

function Set-SPEnterpriseSearchAdministrationComponent
{
    # Mock stub for Set-SPEnterpriseSearchAdministrationComponent
}

function Set-SPEnterpriseSearchContentEnrichmentConfiguration
{
    # Mock stub for Set-SPEnterpriseSearchContentEnrichmentConfiguration
}

function Set-SPEnterpriseSearchCrawlContentSource
{
    # Mock stub for Set-SPEnterpriseSearchCrawlContentSource
}

function Set-SPEnterpriseSearchCrawlDatabase
{
    # Mock stub for Set-SPEnterpriseSearchCrawlDatabase
}

function Set-SPEnterpriseSearchCrawlLogReadPermission
{
    # Mock stub for Set-SPEnterpriseSearchCrawlLogReadPermission
}

function Set-SPEnterpriseSearchCrawlRule
{
    # Mock stub for Set-SPEnterpriseSearchCrawlRule
}

function Set-SPEnterpriseSearchFileFormatState
{
    # Mock stub for Set-SPEnterpriseSearchFileFormatState
}

function Set-SPEnterpriseSearchLinguisticComponentsStatus
{
    # Mock stub for Set-SPEnterpriseSearchLinguisticComponentsStatus
}

function Set-SPEnterpriseSearchLinksDatabase
{
    # Mock stub for Set-SPEnterpriseSearchLinksDatabase
}

function Set-SPEnterpriseSearchMetadataCategory
{
    # Mock stub for Set-SPEnterpriseSearchMetadataCategory
}

function Set-SPEnterpriseSearchMetadataCrawledProperty
{
    # Mock stub for Set-SPEnterpriseSearchMetadataCrawledProperty
}

function Set-SPEnterpriseSearchMetadataManagedProperty
{
    # Mock stub for Set-SPEnterpriseSearchMetadataManagedProperty
}

function Set-SPEnterpriseSearchMetadataMapping
{
    # Mock stub for Set-SPEnterpriseSearchMetadataMapping
}

function Set-SPEnterpriseSearchPrimaryHostController
{
    # Mock stub for Set-SPEnterpriseSearchPrimaryHostController
}

function Set-SPEnterpriseSearchQueryAuthority
{
    # Mock stub for Set-SPEnterpriseSearchQueryAuthority
}

function Set-SPEnterpriseSearchQueryKeyword
{
    # Mock stub for Set-SPEnterpriseSearchQueryKeyword
}

function Set-SPEnterpriseSearchQueryScope
{
    # Mock stub for Set-SPEnterpriseSearchQueryScope
}

function Set-SPEnterpriseSearchQueryScopeRule
{
    # Mock stub for Set-SPEnterpriseSearchQueryScopeRule
}

function Set-SPEnterpriseSearchQuerySpellingCorrection
{
    # Mock stub for Set-SPEnterpriseSearchQuerySpellingCorrection
}

function Set-SPEnterpriseSearchRankingModel
{
    # Mock stub for Set-SPEnterpriseSearchRankingModel
}

function Set-SPEnterpriseSearchResultItemType
{
    # Mock stub for Set-SPEnterpriseSearchResultItemType
}

function Set-SPEnterpriseSearchResultSource
{
    # Mock stub for Set-SPEnterpriseSearchResultSource
}

function Set-SPEnterpriseSearchService
{
    # Mock stub for Set-SPEnterpriseSearchService
}

function Set-SPEnterpriseSearchServiceApplication
{
    # Mock stub for Set-SPEnterpriseSearchServiceApplication
}

function Set-SPEnterpriseSearchServiceApplicationProxy
{
    # Mock stub for Set-SPEnterpriseSearchServiceApplicationProxy
}

function Set-SPEnterpriseSearchServiceInstance
{
    # Mock stub for Set-SPEnterpriseSearchServiceInstance
}

function Set-SPEnterpriseSearchTopology
{
    # Mock stub for Set-SPEnterpriseSearchTopology
}

function Set-SPFarmConfig
{
    # Mock stub for Set-SPFarmConfig
}

function Set-SPInfoPathFormsService
{
    # Mock stub for Set-SPInfoPathFormsService
}

function Set-SPInfoPathFormTemplate
{
    # Mock stub for Set-SPInfoPathFormTemplate
}

function Set-SPInfoPathWebServiceProxy
{
    # Mock stub for Set-SPInfoPathWebServiceProxy
}

function Set-SPInternalAppStateUpdateInterval
{
    # Mock stub for Set-SPInternalAppStateUpdateInterval
}

function Set-SPIRMSettings
{
    # Mock stub for Set-SPIRMSettings
}

function Set-SPLogLevel
{
    # Mock stub for Set-SPLogLevel
}

function Set-SPManagedAccount
{
    # Mock stub for Set-SPManagedAccount
}

function Set-SPMetadataServiceApplication
{
    # Mock stub for Set-SPMetadataServiceApplication
}

function Set-SPMetadataServiceApplicationProxy
{
    # Mock stub for Set-SPMetadataServiceApplicationProxy
}

function Set-SPMicrofeedOptions
{
    # Mock stub for Set-SPMicrofeedOptions
}

function Set-SPMobileMessagingAccount
{
    # Mock stub for Set-SPMobileMessagingAccount
}

function Set-SPO365LinkSettings
{
    # Mock stub for Set-SPO365LinkSettings
}

function Set-SPODataConnectionSetting
{
    # Mock stub for Set-SPODataConnectionSetting
}

function Set-SPODataConnectionSettingMetadata
{
    # Mock stub for Set-SPODataConnectionSettingMetadata
}

function Set-SPOfficeStoreAppsDefaultActivation
{
    # Mock stub for Set-SPOfficeStoreAppsDefaultActivation
}

function Set-SPPassPhrase
{
    # Mock stub for Set-SPPassPhrase
}

function Set-SPPerformancePointSecureDataValues
{
    # Mock stub for Set-SPPerformancePointSecureDataValues
}

function Set-SPPerformancePointServiceApplication
{
    # Mock stub for Set-SPPerformancePointServiceApplication
}

function Set-SPPowerPointConversionServiceApplication
{
    # Mock stub for Set-SPPowerPointConversionServiceApplication
}

function Set-SPProfileServiceApplication
{
    # Mock stub for Set-SPProfileServiceApplication
}

function Set-SPProfileServiceApplicationProxy
{
    # Mock stub for Set-SPProfileServiceApplicationProxy
}

function Set-SPProfileServiceApplicationSecurity
{
    # Mock stub for Set-SPProfileServiceApplicationSecurity
}

function Set-SPProjectDatabaseQuota
{
    # Mock stub for Set-SPProjectDatabaseQuota
}

function Set-SPProjectEventServiceSettings
{
    # Mock stub for Set-SPProjectEventServiceSettings
}

function Set-SPProjectOdataConfiguration
{
    # Mock stub for Set-SPProjectOdataConfiguration
}

function Set-SPProjectPCSSettings
{
    # Mock stub for Set-SPProjectPCSSettings
}

function Set-SPProjectPermissionMode
{
    # Mock stub for Set-SPProjectPermissionMode
}

function Set-SPProjectQueueSettings
{
    # Mock stub for Set-SPProjectQueueSettings
}

function Set-SPProjectServiceApplication
{
    # Mock stub for Set-SPProjectServiceApplication
}

function Set-SPProjectUserSync
{
    # Mock stub for Set-SPProjectUserSync
}

function Set-SPProjectUserSyncDisabledSyncThreshold
{
    # Mock stub for Set-SPProjectUserSyncDisabledSyncThreshold
}

function Set-SPProjectUserSyncFullSyncThreshold
{
    # Mock stub for Set-SPProjectUserSyncFullSyncThreshold
}

function Set-SPProjectUserSyncOffPeakSyncThreshold
{
    # Mock stub for Set-SPProjectUserSyncOffPeakSyncThreshold
}

function Set-SPRequestManagementSettings
{
    # Mock stub for Set-SPRequestManagementSettings
}

function Set-SPRoutingMachineInfo
{
    # Mock stub for Set-SPRoutingMachineInfo
}

function Set-SPRoutingMachinePool
{
    # Mock stub for Set-SPRoutingMachinePool
}

function Set-SPRoutingRule
{
    # Mock stub for Set-SPRoutingRule
}

function Set-SPScaleOutDatabaseDataRange
{
    # Mock stub for Set-SPScaleOutDatabaseDataRange
}

function Set-SPScaleOutDatabaseDataSubRange
{
    # Mock stub for Set-SPScaleOutDatabaseDataSubRange
}

function Set-SPSecureStoreApplication
{
    # Mock stub for Set-SPSecureStoreApplication
}

function Set-SPSecureStoreDefaultProvider
{
    # Mock stub for Set-SPSecureStoreDefaultProvider
}

function Set-SPSecureStoreServiceApplication
{
    # Mock stub for Set-SPSecureStoreServiceApplication
}

function Set-SPSecurityTokenServiceConfig
{
    # Mock stub for Set-SPSecurityTokenServiceConfig
}

function Set-SPServer
{
    # Mock stub for Set-SPServer
}

function Set-SPServerScaleOutDatabaseDataRange
{
    # Mock stub for Set-SPServerScaleOutDatabaseDataRange
}

function Set-SPServerScaleOutDatabaseDataSubRange
{
    # Mock stub for Set-SPServerScaleOutDatabaseDataSubRange
}

function Set-SPServiceApplication
{
    # Mock stub for Set-SPServiceApplication
}

function Set-SPServiceApplicationEndpoint
{
    # Mock stub for Set-SPServiceApplicationEndpoint
}

function Set-SPServiceApplicationPool
{
    # Mock stub for Set-SPServiceApplicationPool
}

function Set-SPServiceApplicationSecurity
{
    # Mock stub for Set-SPServiceApplicationSecurity
}

function Set-SPServiceHostConfig
{
    # Mock stub for Set-SPServiceHostConfig
}

function Set-SPSessionStateService
{
    # Mock stub for Set-SPSessionStateService
}

function Set-SPSite
{
    # Mock stub for Set-SPSite
}

function Set-SPSiteAdministration
{
    # Mock stub for Set-SPSiteAdministration
}

function Set-SPSiteSubscriptionConfig
{
    # Mock stub for Set-SPSiteSubscriptionConfig
}

function Set-SPSiteSubscriptionEdiscoveryHub
{
    # Mock stub for Set-SPSiteSubscriptionEdiscoveryHub
}

function Set-SPSiteSubscriptionIRMConfig
{
    # Mock stub for Set-SPSiteSubscriptionIRMConfig
}

function Set-SPSiteSubscriptionMetadataConfig
{
    # Mock stub for Set-SPSiteSubscriptionMetadataConfig
}

function Set-SPSiteSubscriptionProfileConfig
{
    # Mock stub for Set-SPSiteSubscriptionProfileConfig
}

function Set-SPSiteURL
{
    # Mock stub for Set-SPSiteURL
}

function Set-SPStateServiceApplication
{
    # Mock stub for Set-SPStateServiceApplication
}

function Set-SPStateServiceApplicationProxy
{
    # Mock stub for Set-SPStateServiceApplicationProxy
}

function Set-SPStateServiceDatabase
{
    # Mock stub for Set-SPStateServiceDatabase
}

function Set-SPSubscriptionSettingsServiceApplication
{
    # Mock stub for Set-SPSubscriptionSettingsServiceApplication
}

function Set-SPThrottlingRule
{
    # Mock stub for Set-SPThrottlingRule
}

function Set-SPTimerJob
{
    # Mock stub for Set-SPTimerJob
}

function Set-SPTopologyServiceApplication
{
    # Mock stub for Set-SPTopologyServiceApplication
}

function Set-SPTopologyServiceApplicationProxy
{
    # Mock stub for Set-SPTopologyServiceApplicationProxy
}

function Set-SPTranslationServiceApplication
{
    # Mock stub for Set-SPTranslationServiceApplication
}

function Set-SPTranslationServiceApplicationProxy
{
    # Mock stub for Set-SPTranslationServiceApplicationProxy
}

function Set-SPTranslationThrottlingSetting
{
    # Mock stub for Set-SPTranslationThrottlingSetting
}

function Set-SPTrustedIdentityTokenIssuer
{
    # Mock stub for Set-SPTrustedIdentityTokenIssuer
}

function Set-SPTrustedRootAuthority
{
    # Mock stub for Set-SPTrustedRootAuthority
}

function Set-SPTrustedSecurityTokenIssuer
{
    # Mock stub for Set-SPTrustedSecurityTokenIssuer
}

function Set-SPTrustedServiceTokenIssuer
{
    # Mock stub for Set-SPTrustedServiceTokenIssuer
}

function Set-SPUsageApplication
{
    # Mock stub for Set-SPUsageApplication
}

function Set-SPUsageDefinition
{
    # Mock stub for Set-SPUsageDefinition
}

function Set-SPUsageService
{
    # Mock stub for Set-SPUsageService
}

function Set-SPUser
{
    # Mock stub for Set-SPUser
}

function Set-SPVisioExternalData
{
    # Mock stub for Set-SPVisioExternalData
}

function Set-SPVisioPerformance
{
    # Mock stub for Set-SPVisioPerformance
}

function Set-SPVisioSafeDataProvider
{
    # Mock stub for Set-SPVisioSafeDataProvider
}

function Set-SPVisioServiceApplication
{
    # Mock stub for Set-SPVisioServiceApplication
}

function Set-SPWeb
{
    # Mock stub for Set-SPWeb
}

function Set-SPWebApplication
{
    # Mock stub for Set-SPWebApplication
}

function Set-SPWebApplicationHttpThrottlingMonitor
{
    # Mock stub for Set-SPWebApplicationHttpThrottlingMonitor
}

function Set-SPWOPIBinding
{
    # Mock stub for Set-SPWOPIBinding
}

function Set-SPWOPIZone
{
    # Mock stub for Set-SPWOPIZone
}

function Set-SPWordConversionServiceApplication
{
    # Mock stub for Set-SPWordConversionServiceApplication
}

function Set-SPWorkflowConfig
{
    # Mock stub for Set-SPWorkflowConfig
}

function Set-SPWorkManagementServiceApplication
{
    # Mock stub for Set-SPWorkManagementServiceApplication
}

function Set-SPWorkManagementServiceApplicationProxy
{
    # Mock stub for Set-SPWorkManagementServiceApplicationProxy
}

function Split-SPScaleOutDatabase
{
    # Mock stub for Split-SPScaleOutDatabase
}

function Split-SPServerScaleOutDatabase
{
    # Mock stub for Split-SPServerScaleOutDatabase
}

function Start-SPAdminJob
{
    # Mock stub for Start-SPAdminJob
}

function Start-SPAssignment
{
    # Mock stub for Start-SPAssignment
}

function Start-SPContentDeploymentJob
{
    # Mock stub for Start-SPContentDeploymentJob
}

function Start-SPDiagnosticsSession
{
    # Mock stub for Start-SPDiagnosticsSession
}

function Start-SPEnterpriseSearchQueryAndSiteSettingsServiceInstance
{
    # Mock stub for Start-SPEnterpriseSearchQueryAndSiteSettingsServiceInstance
}

function Start-SPEnterpriseSearchServiceInstance
{
    # Mock stub for Start-SPEnterpriseSearchServiceInstance
}

function Start-SPInfoPathFormTemplate
{
    # Mock stub for Start-SPInfoPathFormTemplate
}

function Start-SPProjectGenerateWsdl
{
    # Mock stub for Start-SPProjectGenerateWsdl
}

function Start-SPService
{
    # Mock stub for Start-SPService
}

function Start-SPServiceInstance
{
    # Mock stub for Start-SPServiceInstance
}

function Start-SPTimerJob
{
    # Mock stub for Start-SPTimerJob
}

function Stop-SPAssignment
{
    # Mock stub for Stop-SPAssignment
}

function Stop-SPContentTypeReplication
{
    # Mock stub for Stop-SPContentTypeReplication
}

function Stop-SPDiagnosticsSession
{
    # Mock stub for Stop-SPDiagnosticsSession
}

function Stop-SPDistributedCacheServiceInstance
{
    # Mock stub for Stop-SPDistributedCacheServiceInstance
}

function Stop-SPEnterpriseSearchQueryAndSiteSettingsServiceInstance
{
    # Mock stub for Stop-SPEnterpriseSearchQueryAndSiteSettingsServiceInstance
}

function Stop-SPEnterpriseSearchServiceInstance
{
    # Mock stub for Stop-SPEnterpriseSearchServiceInstance
}

function Stop-SPInfoPathFormTemplate
{
    # Mock stub for Stop-SPInfoPathFormTemplate
}

function Stop-SPService
{
    # Mock stub for Stop-SPService
}

function Stop-SPServiceInstance
{
    # Mock stub for Stop-SPServiceInstance
}

function Stop-SPTaxonomyReplication
{
    # Mock stub for Stop-SPTaxonomyReplication
}

function Suspend-SPEnterpriseSearchServiceApplication
{
    # Mock stub for Suspend-SPEnterpriseSearchServiceApplication
}

function Suspend-SPStateServiceDatabase
{
    # Mock stub for Suspend-SPStateServiceDatabase
}

function Sync-SPProjectPermissions
{
    # Mock stub for Sync-SPProjectPermissions
}

function Test-SPContentDatabase
{
    # Mock stub for Test-SPContentDatabase
}

function Test-SPInfoPathFormTemplate
{
    # Mock stub for Test-SPInfoPathFormTemplate
}

function Test-SPO365LinkSettings
{
    # Mock stub for Test-SPO365LinkSettings
}

function Test-SPProjectServiceApplication
{
    # Mock stub for Test-SPProjectServiceApplication
}

function Test-SPProjectWebInstance
{
    # Mock stub for Test-SPProjectWebInstance
}

function Test-SPSite
{
    # Mock stub for Test-SPSite
}

function Uninstall-SPAppInstance
{
    # Mock stub for Uninstall-SPAppInstance
}

function Uninstall-SPDataConnectionFile
{
    # Mock stub for Uninstall-SPDataConnectionFile
}

function Uninstall-SPFeature
{
    # Mock stub for Uninstall-SPFeature
}

function Uninstall-SPHelpCollection
{
    # Mock stub for Uninstall-SPHelpCollection
}

function Uninstall-SPInfoPathFormTemplate
{
    # Mock stub for Uninstall-SPInfoPathFormTemplate
}

function Uninstall-SPSolution
{
    # Mock stub for Uninstall-SPSolution
}

function Uninstall-SPUserSolution
{
    # Mock stub for Uninstall-SPUserSolution
}

function Uninstall-SPWebPartPack
{
    # Mock stub for Uninstall-SPWebPartPack
}

function Unpublish-SPServiceApplication
{
    # Mock stub for Unpublish-SPServiceApplication
}

function Update-SPAppCatalogConfiguration
{
    # Mock stub for Update-SPAppCatalogConfiguration
}

function Update-SPAppInstance
{
    # Mock stub for Update-SPAppInstance
}

function Update-SPDistributedCacheSize
{
    # Mock stub for Update-SPDistributedCacheSize
}

function Update-SPFarmEncryptionKey
{
    # Mock stub for Update-SPFarmEncryptionKey
}

function Update-SPHelp
{
    # Mock stub for Update-SPHelp
}

function Update-SPInfoPathAdminFileUrl
{
    # Mock stub for Update-SPInfoPathAdminFileUrl
}

function Update-SPInfoPathFormTemplate
{
    # Mock stub for Update-SPInfoPathFormTemplate
}

function Update-SPInfoPathUserFileUrl
{
    # Mock stub for Update-SPInfoPathUserFileUrl
}

function Update-SPProfilePhotoStore
{
    # Mock stub for Update-SPProfilePhotoStore
}

function Update-SPRepopulateMicroblogFeedCache
{
    # Mock stub for Update-SPRepopulateMicroblogFeedCache
}

function Update-SPRepopulateMicroblogLMTCache
{
    # Mock stub for Update-SPRepopulateMicroblogLMTCache
}

function Update-SPSecureStoreApplicationServerKey
{
    # Mock stub for Update-SPSecureStoreApplicationServerKey
}

function Update-SPSecureStoreCredentialMapping
{
    # Mock stub for Update-SPSecureStoreCredentialMapping
}

function Update-SPSecureStoreGroupCredentialMapping
{
    # Mock stub for Update-SPSecureStoreGroupCredentialMapping
}

function Update-SPSecureStoreMasterKey
{
    # Mock stub for Update-SPSecureStoreMasterKey
}

function Update-SPSolution
{
    # Mock stub for Update-SPSolution
}

function Update-SPUserSolution
{
    # Mock stub for Update-SPUserSolution
}

function Update-SPWOPIProofKey
{
    # Mock stub for Update-SPWOPIProofKey
}

function Upgrade-SPAppManagementServiceApplication
{
    # Mock stub for Upgrade-SPAppManagementServiceApplication
}

function Upgrade-SPContentDatabase
{
    # Mock stub for Upgrade-SPContentDatabase
}

function Upgrade-SPEnterpriseSearchServiceApplication
{
    # Mock stub for Upgrade-SPEnterpriseSearchServiceApplication
}

function Upgrade-SPEnterpriseSearchServiceApplicationSiteSettings
{
    # Mock stub for Upgrade-SPEnterpriseSearchServiceApplicationSiteSettings
}

function Upgrade-SPFarm
{
    # Mock stub for Upgrade-SPFarm
}

function Upgrade-SPProfileServiceApplication
{
    # Mock stub for Upgrade-SPProfileServiceApplication
}

function Upgrade-SPSingleSignOnDatabase
{
    # Mock stub for Upgrade-SPSingleSignOnDatabase
}

function Upgrade-SPSite
{
    # Mock stub for Upgrade-SPSite
}

function Upgrade-SPSiteMapDatabase
{
    # Mock stub for Upgrade-SPSiteMapDatabase
}