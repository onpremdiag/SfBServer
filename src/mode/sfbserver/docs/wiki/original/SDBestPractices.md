# Skype for Business Server Deployment Best Practices Analyzer (Work in Progress)
**Owner:** David Paulino

#Description
This scenario checks if the Skype for Business Server is following the Best Practices. For more details please refer to the following articles: TO_DO

[[_TOC_]]

#Execution flow<br/>

**Scenario**  -------> Analyzer --------> Rules

::: mermaid
graph LR

  SDBestPractice(SDBestPractice) --1--> ADSfBServerPatchVersion[ADSfBServerPatchVersion]
  SDBestPractice --2--> ADSQLExpressVersion[ADSQLExpressVersion]
  SDBestPractice --3--> ADSQLServerLargeTransactionLog[ADSQLServerLargeTransactionLog]
  SDBestPractice --4--> ADSQLSchemaVersionMismatch[ADSQLSchemaVersionMismatch]
  SDBestPractice --5--> ADHWServerSpecs[ADHWServerSpecs]
  SDBestPractice --6--> ADSocketCoreRatio[ADSocketCoreRatio]
  SDBestPractice --7--> ADMultihomedServer[ADMultihomedServer]
  SDBestPractice --8--> ADNetworkBinding[ADNetworkBinding]
  SDBestPractice --9--> ADFrontEndUserCount[ADFrontEndUserCount]
  SDBestPractice --10--> ADDNSPoolConfig[ADDNSPoolConfig]

  ADSfBServerPatchVersion --1.1--> RDSfBServerPatchVersion[RDSfBServerPatchVersion]
  ADLocalSQLVersion --2.1--> RDLocalSQLVersion[RDLocalSQLVersion]
  ADSQLServerLargeTransactionLog --3.1--> RDSQLServerLargeTransactionLog[RDSQLServerLargeTransactionLog]
  ADSQLSchemaVersionMismatch --4.1--> RDCheckLocalSQLServerSchemaVersion[RDCheckLocalSQLServerSchemaVersion]
  ADHWServerSpecs --5.1--> RDServerPhysicalOrVirtual[RDServerPhysicalOrVirtual]
  ADHWServerSpecs --5.2--> RDServerCores[RDServerCores]
  ADHWServerSpecs --5.3--> RDServerMemory[RDServerMemory]
  ADSocketCoreRatio --6.1--> RDServerSocketCoreRatio[RDServerSocketCoreRatio]
  ADMultihomedServer --7.1--> RDMultihomedServer[RDMultihomedServer]
  ADNetworkBinding --8.1--> RDRTCSrvBinding[RDRTCSrvBinding]
  ADFrontEndUserCount --9.1--> RDFrontEndUserCount[RDFrontEndUserCount]
  ADDNSPoolConfig --10.1--> RDDNSPoolConfig[RDDNSPoolConfig]

:::

#Rules specifications<br/>

### RDSfBServerPatchVersion
Check if Skype for Business Server is running with latest cumulative update
Get-csServerPatchVersion and compare the existing components with the latest ones available

### RDLocalSQLVersion
Check if the Local SQL Express version is running on the latest service pack/cumulative update
invoke-sqlcmd -query "Select @@VERSION" -ServerInstance localhost\RTCLOCAL

SQL Express 2014 – 12.0.6024.0
SQL Express 2016 – 13.0.5026.0

### RDCheckLocalSQLServerSchemaVersion
Check if SQL Server schema expected version matches with installed version
Test-CsDatabase -LocalService -WarningAction SilentlyContinue
foreach($csLocalDatabase in ($csLocalDatabases | `
Where-Object {[string]$.ExpectedVersion -ne [string]$.InstalledVersion}))

### RDServerPhysicalOrVirtual
Check if the server is physical or a virtual machine
TO_DO

### RDServerCores
Check the number of CPU Cores available
Get-WmiObject -class "Win32_ComputerSystem" | Select @{N="Memory (GB)";E={[math]::Round($_.TotalPhysicalMemory/(1024*1024*1024))}}, NumberOfProcessors, NumberOfLogicalProcessors
NumberOfLogicalProcessors >=12

### RDServerMemory
Check the total memory available
Get-WmiObject -class "Win32_ComputerSystem" | Select @{N="Memory (GB)";E={[math]::Round($_.TotalPhysicalMemory/(1024*1024*1024))}}, NumberOfProcessors, NumberOfLogicalProcessors
Memory (GB) >= 32 for Skype for Business Server 2015 and Skype for Business Server 2019 Std Edition
Memory (GB) >= 64 for Skype for Business Server 2019 Enterprise Edition Front Ends.
Server requirements for Skype for Business Server 2015
https://docs.microsoft.com/en-us/skypeforbusiness/plan-your-deployment/requirements-for-your-environment/server-requirements
System requirements for Skype for Business Server 2019
https://docs.microsoft.com/en-us/skypeforbusiness/plan/system-requirements

### RDServerSocketCoreRatio
Check CPU Cores assigned to SQL Server Express
$SQLCores = (invoke-sqlcmd -query "select cpu_count from sys.dm_os_sys_info” -ServerInstance localhost\RTCLOCAL).cpu_count
$SQLCores needs to be equal to 4, since SQL express has a limitation related to the number of cores per socket:
SQL Express - Limited to lesser of 1 Socket or 4 cores
https://docs.microsoft.com/en-us/sql/sql-server/compute-capacity-limits-by-edition-of-sql-server

### RDMultihomedServer
(Warning) Check if server has more than one Network Interface connected and with an IP.
(Get-NetIPAddress -AddressFamily IPv4 -Type Unicast | ?{$_.PrefixOrigin -ne 'WellKnown'}).count == 1
Note: The excludes the local loopback (127.0.0.1) and also the (169.254.0.0) that is assigned when interface is UP but no DHCP/Static address available.

### RDRTCSrvBinding
Check if Front End service is configured to Listen to All interfaces
(Get-NetTCPConnection -LocalPort 5061 -State Listen).LocalAddress -eq “0.0.0.0”

### RDFrontEndUserCount
Checks total users assigned to this server (including SBA users)
TO_DO

### RDDNSPoolConfig
Check if server IP is in the DNS record for the pool name (Except if HLB)


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
| en-us    | SDBestPractice| Skype for Business Server Deployment Best Practices Analyzer |

###Analyzer description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | ADSfBServerVersion| Verify if the SfB all Components are running on the latest cumulative update. |
| en-us    | ADSQLExpressVersion| Verify if the Local SQL Instances are running the latest service pack/cumulative update |
| en-us    | ADSQLServerLargeTransactionLog| Verify if the Transaction Log on rtcxds is too large. |
| en-us    | ADSQLSchemaVersionMismatch| Verify if there is an update database missing from the Databases used by this server. |
| en-us    | ADHWServerSpecs|  Verify if the server has the recommended Hardware Requirements. |
| en-us    | ADSocketToCoreRatio|  Verify if the SQL Server Express is running on 4 cores. |
| en-us    | ADMultihomedNetwork|  Verify if the current Front End has more than one Network Interface on different networks.|
| en-us    | ADNetworkBinding|  Verify if the Front End service is configured to listen on all interfaces. |
| en-us    | ADFrontEndUserCount|  Verify how many users are currently assigned to this Front End, including SBA users.|
| en-us    | ADDNSPoolConfig| Verify if the current server is part of a pool and if the IP address is on DNS record for the pool. (Only if DNS LB in use). |


###Rule description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | RDSfBServerPatchVersion| Determine if Skype for Business Server is running with latest cumulative update. |
| en-us    | RDLocalSQLVersion| Determine if the Local SQL Express version is running on the latest service pack/cumulative update. |
| en-us    | RDCheckLocalSQLServerSchemaVersion| Determine if SQL Server schema expected version matches with installed version. |
| en-us    | RDServerPhysicalOrVirtual| Determine if the server is physical or a virtual machine. |
| en-us    | RDServerCores| Determine the total number of CPU Cores available. |
| en-us    | RDServerMemory| Determine the total memory available. |
| en-us    | RDServerSocketCoreRatio| Determine how many cores are assigned to SQL Express. |
| en-us    | RDMultihomedServer| Determine if server has more than one Network Interface connected and with an IP. |
| en-us    | RDRTCSrvBinding| Determine if server has more than one Network Interface connected and with an IP. |
| en-us    | RDFrontEndUserCount| Determine if the edge server is reachable (ping) |
| en-us    | RDDNSPoolConfig| Determine if server IP is in the DNS record for the pool name (Exclude HLB) |


###Insight detection description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | TO_DO| TO_DO|

###Insight action description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | TO_DO| TO_DO|
