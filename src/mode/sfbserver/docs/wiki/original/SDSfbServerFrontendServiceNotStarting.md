#Skype for Business Server Frontend service is not starting
**Owner:** David Paulino
#Description

This scenario checks common root cause issues why Skype for Business Server frontend service is not starting correctly.

[[_TOC_]]

#Execution flow<br/>

**Scenario**  -------> Analyzer --------> Rules

::: mermaid
graph LR
SDSfbServerFrontendServiceNotStarting(SDSfbServerFrontendServiceNotStarting)--1--> ADCheckLocalSQLServerInstanceAndDBs[ADCheckLocalSQLServerInstanceAndDBs]
SDSfbServerFrontendServiceNotStarting(SDSfbServerFrontendServiceNotStarting)--2--> ADIsSfbServerCertificateValid[ADIsSfbServerCertificateValid]
SDSfbServerFrontendServiceNotStarting(SDSfbServerFrontendServiceNotStarting)--3--> ADCheckRootCACertificates[ADCheckRootCACertificates]
SDSfbServerFrontendServiceNotStarting(SDSfbServerFrontendServiceNotStarting)--4--> ADIsSQLBackendConnectionAvailable[ADIsSQLBackendConnectionAvailable]
SDSfbServerFrontendServiceNotStarting(SDSfbServerFrontendServiceNotStarting)--5--> ADCheckQuorumLoss[ADCheckQuorumLoss]
SDSfbServerFrontendServiceNotStarting(SDSfbServerFrontendServiceNotStarting)--6--> ADCheckSChannelRegistryKeys[ADCheckSChannelRegistryKeys]

ADCheckLocalSQLServerInstanceAndDBs --1.1--> RDCheckSQLServicesAreRunning[RDCheckSQLServicesAreRunning]
ADCheckLocalSQLServerInstanceAndDBs --1.2--> RDCheckSFBLocalDBsSingleUserMode[RDCheckSFBLocalDBsSingleUserMode]
ADCheckLocalSQLServerInstanceAndDBs --1.3--> RDCheckLocalSQLServerSchemaVersion[RDCheckLocalSQLServerSchemaVersion]
ADIsSfbServerCertificateValid --2.1--> RDCheckSfbServerCertificateExpired[RDCheckSfbServerCertificateExpired]
ADCheckRootCACertificates --3.2--> RDCheckMisplacedRootCACertificates[RDCheckMisplacedRootCACertificates]
ADCheckRootCACertificates --3.2--> RDCheckTooManyCertsRootCA[RDCheckTooManyCertsRootCA]
ADIsSQLBackendConnectionAvailable --4.1--> RDCheckSQLServerBackendConnection[RDCheckSQLServerBackendConnection]
ADCheckQuorumLoss --5.1--> RDCheckDNSResolution[RDCheckDNSResolution]
ADCheckQuorumLoss --5.2--> RDCheckSfbServerQuorumLoss[RDCheckSfbServerQuorumLoss]
ADCheckSChannelRegistryKeys --6.1--> RDCheckSchannelSessionTicket[RDCheckSchannelSessionTicket]
ADCheckSChannelRegistryKeys --6.2--> RDCheckSchannelTrustMode[RDCheckSchannelTrustMode]
:::

#Rules specifications<br/>

###RDCheckSQLServicesAreRunning
Check if SQL Server are running

Get-Service -DisplayName "SQL Server (*)"
###RDCheckSFBLocalDBsSingleUserMode
Check if SQL Server databases are in single user mode

$SQLServer = ".\RTCLOCAL"
        $SQLQuery  = "SELECT  name FROM sys.databases WHERE name IN ('rtc','rtcdyn') and (state != 0 or user_access_desc = 'SINGLE_USER');"
###RDCheckLocalSQLServerSchemaVersion
Check if SQL Server schema expected version matches with installed version

Test-CsDatabase -LocalService -WarningAction SilentlyContinue
        foreach(\$csLocalDatabase in (\$csLocalDatabases | `
                                             Where-Object {[string]\$_.ExpectedVersion -ne [string]\$_.InstalledVersion}))
###RDCheckSfbServerCertificateExpired
Check if Skype for Business Server certificate is expired

\$validCertificates = @(Get-CsCertificate -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Where-Object {\$\_.NotAfter -ge (Get-Date) -and \$_.Use -eq "Default"})
###RDCheckMisplacedRootCACertificates
Check for misplaced certificates in root CA

Get-Childitem \$global:LocalMachineCertificateStore -Recurse | Where-Object {$\_.Issuer -ne $_.Subject}
###RDCheckTooManyCertsRootCA
Check if there are too many certificates in RootCA

Get-ChildItem -Path \$global:LocalMachineCertificateStore -ErrorAction SilentlyContinue
###RDCheckSQLServerBackendConnection
Check if SQL Server backend connection is available

Test-CsDatabase -ConfiguredDatabases -SqlServerFqdn \$BackendFqdn
###RDCheckDNSResolution
Check if frontend DNS A record can be resolved

Resolve-DnsName -Name \$FE.Fqdn -Type A -DnsOnly | Where-Object {$_.Section -eq 'Answer'}

###RDCheckSfbServerQuorumLoss
Check if we have enough frontends to archive quorum

Test-NetConnection -ComputerName $FE.Fqdn -Port 5090 (for each frontend)

###RDCheckSchannelSessionTicket
Check if EnableSessionTicket registry key exists and set to 2

###RDCheckSchannelTrustMode
Check if ClientAuthTrustMode registry key exists and set to 2 -'Exclusive CA Trust'

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
| en-us    | SDSfbServerFrontendServiceNotStarting| Skype for Business Server Frontend service is not starting |

###Analyzer description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | ADCheckLocalSQLServerInstanceAndDBs| Verifies if local SQL Server instances are running, databases are not in single user mode and schema version is correct |
| en-us    | ADIsSfbServerCertificateValid| Verifies if Skype for Business Server Frontend certificate is not expired |
| en-us    | ADCheckRootCACertificates| Verifies the local machine certificate store configuration is correct |
| en-us    | ADIsSQLBackendConnectionAvailable| Verifies if local SQL Server instances are running, databases are not in single user mode and schema version is correct |
| en-us    | ADCheckQuorumLoss| Verifies if minimum required number of servers to have quorum are up and running |
| en-us    | ADCheckSChannelRegistryKeys| Verifies the schannel client authentication trust mode and session ticket TLS optimization registry keys configuration |

###Rule description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | RDCheckSQLServicesAreRunning| Determine if local SQL Server services are running |
| en-us    | RDCheckSFBLocalDBsSingleUserMode| Determine if local Skype for Business Server databases are in single user mode |
| en-us    | RDCheckLocalSQLServerSchemaVersion| Determine if local SQL Server database installed version is different than expected version |
| en-us    | RDCheckSfbServerCertificateExpired| Determine if Skype for Business Server Frontend certificate is expired |
| en-us    | RDCheckMisplacedRootCACertificates| Determine if there are misplaced certificates in local machine Root system store |
| en-us    | RDCheckTooManyCertsRootCA| Determine if there are too many certificates in local machine root CA store |
| en-us    | RDCheckSQLServerBackendConnection | Determine if SQL Server backend connectivity is available |
| en-us    | RDCheckDNSResolution| Determine if the IPv4 address can be resolved and the reverse lookup matches |
| en-us    | RDCheckSfbServerQuorumLoss| Determine if minimum number of frontend servers required to start pool are available |
| en-us    | RDCheckSchannelSessionTicket| Determine if Schannel session ticket TLS optimization is enabled |
| en-us    | RDCheckSchannelTrustMode|Determine if Schannel client authentication trust mode registry key is set to exclusive CA |

###Insight detection description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | IDSQLServicesNotRunning| At least one local SQL Server service is not started. |
| en-us    | IDSFBLocalDBsAreInSingleUserMode| The Skype for Business Server local database '{0}' is either single user mode or offline status. |
| en-us    | IDLocalSQLServerSchemaVersionMismatch| The Skype for Business Server local database: '{0}', installed version: '{1}', does not match expected version: '{2}'. |
| en-us    | IDSfbServerCertificateIsExpired| The Skype for Business Server certificate is either expired or not set. |
| en-us    | IDRootCACertificatesMisplaced| There are {0} certificates incorrectly stored on the local computer Trusted Root Certification Authorities store. |
| en-us    | IDTooManyCertsInRootCA| There are {0} certificates in local computer 'Trusted Root Certification Authorities' store. |
| en-us    | IDSQLServerBackendConnectionIsDown| The Skype for Business Server SQL backend connectivity to '{0}' is not available. |
| en-us    | IDIPv4DoesNotMatchReverseLookup| DNS IPv4 name does not match reverse DNS lookup. Expected: {0}, Actual: {1} |
| en-us    | IDSfbServerNoQuorum| Only {0} out of {1} Skype for Business Server frontend seem to be running. |
| en-us    | IDSchannelSessionTicketNotDisabled| Schannel session ticket TLS optimization is enabled. In earlier OS builds TLS problems may occur if TLS optimization is enabled. |
| en-us    | IDSchannelTrustModeNotSet| Schannel client authentication mode is not configured to 'exclusive CA trust'. |

###Insight action description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | IDSQLServicesNotRunning| Please start SQL Server services by running Start-Service -DisplayName "SQL Server (*)" powershell command. |
| en-us    | IDSFBLocalDBsAreInSingleUserMode| Please reinstall latest Skype for Business Server cumulative update and confirm deployemnt completes without any failure. |
| en-us    | IDLocalSQLServerSchemaVersionMismatch| Please install latest Skype for Business Server cumulative update. |
| en-us    | IDSfbServerCertificateIsExpired| Please assign or renew Skype for Business Server certificate as described at shttps://docs.microsoft.com/en-us/skypeforbusiness/deploy/install/install-skype-for-business-server. |
| en-us    | IDRootCACertificatesMisplaced| Please move certificates that are incorrectly stored in Trusted Root Certification Authorities store to proper store. You can identify misplaced certificate by running the following powershell command: Get-Childitem cert:\LocalMachine\root -Recurse | Where-Object {$_.Issuer -ne $_.Subject} | Format-List * |
| en-us    | IDTooManyCertsInRootCA| Local computer 'Trusted Root Certification Authorities' store should have less than {0} certificates. Please remove certificates incorrectly stored. |
| en-us    | IDSQLServerBackendConnectionIsDown| Please make sure that SQL Server backend services are running and firewall SQL exceptions are in place.SQL Server backend connectivity can be tested by running Test-CsDatabase -ConfiguredDatabases - SqlSerfverFqdn <SQLBackendFqdn>. |
| en-us    | IDIPv4DoesNotMatchReverseLookup| **TODO** IDIPv4DoesNotMatchReverseLookup |
| en-us    | IDSfbServerNoQuorum| Please execute Start-CsPool -PoolFqdn "{0}" cmdlet. If the problem persists, please follow guidance available at https://docs.microsoft.com/en-us/skypeforbusiness/plan-your-deployment/high-availability-and-disaster-recovery/high-availability. |
| en-us    | IDSchannelSessionTicketNotDisabled| Please disable Schannel session ticket TLS optimization by as described on https://docs.microsoft.com/en-us/skypeforbusiness/troubleshoot/server-configuration/event-32402-61045-front-end. |
| en-us    | IDSchannelTrustModeNotSet| Please set Schannel client authentication trust mode to 'Exclusive CA Trust' as described on https://docs.microsoft.com/en-us/windows-server/security/tls/what-s-new-in-tls-ssl-schannel-ssp-overview. |
