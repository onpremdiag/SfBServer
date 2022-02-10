#User contact list is not available
**Owner:** Robert Panduru

#Description

This scenario checks if Skype for Business user contact list is missing due account being UCS (unified contact store) enabled however exchange connectivity is not available or not properly configured. For more details please refer to [Configure Skype for Business Server to use the unified contact store](https://docs.microsoft.com/en-us/skypeforbusiness/deploy/integrate-with-exchange-server/use-the-unified-contact-store)

[[_TOC_]]

#Execution flow<br/>

Parameters <------ **Scenario**  -------> Analyzer --------> Rules

::: mermaid
graph LR
SDUserContactListIsMissing(SDUserContactListIsMissing)--1--> ADCheckUserUCS[ADCheckUserUCS]

P1[\PDSipAddress\] -.-> SDUserContactListIsMissing

ADCheckUserUCS --1.1--> RDCheckUserUCSConnectivity[RDCheckUserUCSConnectivity]
ADCheckUserUCS --1.2--> RDCheckUserUCSStatus[RDCheckUserUCSStatus]
:::

#Rules specifications<br/>

###RDCheckUserUCSConnectivity

Determine if user contact list can effectively retrieved from Exchange

PS> Test-CsUnifiedContactStore -TargetFqdn $PoolFqdn.Pool -UserSipAddress $currentSipAddress

### RDCheckUserUCSStatus

Determine if user is unified contact store enabled as migration status

PS> $ucsStatus = Debug-CsUnifiedContactStore -Identity $currentSipAddress

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
| en-us    | SDUserContactListIsMissing | User contact list is not available |

###Parameters description, prompt and example<br/>

| Language | Key                        | Description                        | Prompt | Example|
|----------|----------------------------|------------------------------------|--------|--------|
| en-us    | PDSipAddress| The SIP address for the account. Commonly the same as the UPN |User SIP Address | user1@contoso.com \| user@domain.contoso.com|

###Analyzer description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | ADCheckUserUCS | Verifies if user contact list is being accessed through Unified Contact Store |

###Rule description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | RDCheckUserUCSConnectivity | Determine if user contact list can be effectively retrieved from Exchange Server |
| en-us    | RDCheckUserUCSStatus | Determine if user account is enabled for unified contact store and user account has been migrated successfully |

###Insight detection description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | IDUserNotUCSEnabled | The following user account: '{0}' is not enabled for Unified Contact Store. |
| en-us    | IDUCSConnectivityNotAvailable | Server-to-Server authentication between Skype for Business and Exchange is either not configured or the connection is currently down. Note: If user contact list is expected to be empty this error is expected. |
| en-us    | IDUserUCSEnabledNotMigrated | User contact list is ready to be migrated however that can only be completed when user signs-in. |

###Insight action description<br/>

| Language | Key                        | Message                            |
|----------|----------------------------|------------------------------------|
| en-us    | IDUserNotUCSEnabled | No action required as this warning and can be safely ignored. Potential user contact list issues are not related to either UCS or Exchange as user contact list is still residing on SQL. |
| en-us    | IDUCSConnectivityNotAvailable | To address the problem please follow guidance available at https://docs.microsoft.com/en-us/skypeforbusiness/plan-your-deployment/integrate-with-exchange/integrate-with-exchange to configure Exchange integration. Alternatively consider disabling UCS since is no longer default contact list provider. |
| en-us    | IDUserUCSEnabledNotMigrated | Please check if the user has logged in Skype for Business at least once or alternatively consider disabling user for Unified Contact Store. |
