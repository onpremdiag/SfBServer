# Introduction
The **O**n **P**remise **D**iagnostic (**OPD**) for Skype for Business Server is a collection of diagnostic scenarios, analyzers, rules, and insights for diagnosing common issues in the Skype for Business Server 2015 and 2019 On Premise and Hybrid environments.

![image.png](/.attachments/image-c0a21d64-6c92-48c8-9bc1-122e7056e09e.png)

# Getting Started

Skype for Business Server OPD covers many scenarios with various analyzers. To make things more easily identifiable these scenarios are grouped into functional areas. For more information on the issues being covered please reference the table below.

::: mermaid
graph LR

    Areas(Areas) -- 1 --> ContactList(Contact List)
    Areas(Areas) -- 2 --> Deployment(Deployment)
    Areas(Areas) -- 3 --> ExchangeIntegration(Exchange Integration)
    Areas(Areas) -- 4 --> Federation(Federation)
    Areas(Areas) -- 5 --> Hybrid(Hybrid)
    Areas(Areas) -- 6 --> Services(Services)

    ContactList -- 1.1 --> UCListNotAvailable(User contact list is not available)

    Deployment -- 2.1 --> BestPractices(Skype for Business Server deployment best practices)
    Deployment -- 2.2 --> ModernAuth(Check to verify Modern Authentication supportability and configuration)

    ExchangeIntegration -- 3.1 --> HybridDeployment(Checks the integration between Skype for Business Server and Exchange Hybrid deployment)
    ExchangeIntegration -- 3.2 --> OnlineDeployment(Checks the integration between Skype for Business Server and Exchange Online deployment)
    ExchangeIntegration -- 3.3 --> OnPremDeployment(Checks the integration between Skype for Business Server and Exchange OnPrem deployment)

    Federation -- 4.1 --> FedHybrid(Federation is not working - Hybrid deployment)
    Federation -- 4.2 --> FedOnPrem(Federation is not working - OnPrem deployment)

    Hybrid -- 5.1 --> HybridDeploymentProperlyDisabled(Validates that the Skype for Business hybrid deployment is disabled)
    Hybrid -- 5.2 --> HybridFederation(Federation is not working (Hybrid deployment))
    Hybrid -- 5.3 --> PresenceIMNotWorking(IM and Presence problems between On-Premise and online users)

    Services -- 6.1 --> FrontEnd(Skype for Business Server Frontend service is not starting)
:::

---

| **Area** |**Scenario**  |
|--|--|
| **Contact List** | [User contact list is not available](/Tools-and-Data-Collection/SFB-Server-Diagnostics/Contact-List/User-contact-list-is-not-available) |
| **Deployment** | [Check to verify Modern Authentication supportability and configuration](/Tools-and-Data-Collection/SFB-Server-Diagnostics/Deployment/Check-to-verify-Modern-Authentication-supportability-and-configuration) <br/>[Skype for Business Server deployment best practices](/Tools-and-Data-Collection/SFB-Server-Diagnostics/Deployment/Skype-for-Business-Server-deployment-best-practices) |
| **Exchange Integration** | [Checks the integration between Skype for Business Server and Exchange Hybrid deployment](/Tools-and-Data-Collection/SFB-Server-Diagnostics/Federation/Federation-is-not-working-\(OnPrem-deployment\))<br/>[Checks the integration between Skype for Business Server and Exchange Online deployment](/Tools-and-Data-Collection/SFB-Server-Diagnostics/Federation/Federation-is-not-working-\(Hybrid-deployment\))<br/>[Checks the integration between Skype for Business Server and Exchange OnPrem deployment](/Tools-and-Data-Collection/SFB-Server-Diagnostics/Federation/Federation-is-not-working-\(Hybrid-deployment\)) |
| **Federation** | [Federation is not working (OnPrem deployment)](/Tools-and-Data-Collection/SFB-Server-Diagnostics/Federation/Federation-is-not-working-\(OnPrem-deployment\))<br/>[Federation is not working (Hybrid deployment)](/Tools-and-Data-Collection/SFB-Server-Diagnostics/Federation/Federation-is-not-working-\(Hybrid-deployment\))|
| **Hybrid** | [Validates that the Skype for Business hybrid deployment is disabled]()<br/>[Federation is not working (Hybrid deployment)]()<br/>[IM and Presence problems between on-premised and online users](/Tools-and-Data-Collection/SFB-Server-Diagnostics/Hybrid/IM-and-Presence-problems-between-On%2DPremise-and-online-users)|
| **Services** | [Skype for Business Server Frontend service is not starting](/Tools-and-Data-Collection/SFB-Server-Diagnostics/Services/Skype-for-Business-Server-Frontend-service-is-not-starting) |

For detailed scenario information please refer to specifications document by selecting individual scenario listed above.

#Installation Instructions

· Detailed instructions on how to install/upgrade the latest version of OPD can be found [here](https://github.com/onpremdiag/SfbServer/blob/master/docs/Installation.md).

#Operational Instructions

· Detailed instruction on how to operate OPD can be found [here](https://github.com/onpremdiag/SfbServer/blob/master/docs/HowToUse.md).

#Public Announcement

· The full announcement can be found [here](https://techcommunity.microsoft.com/t5/skype-for-business-blog/on-premises-diagnostics-for-skype-for-business-server-are-now/ba-p/1292931).

#Feedback

· Please leave any feedback or concerns at this [Teams Channel](https://teams.microsoft.com/l/team/19%3a250a7094f27c44b88150292c4104ba49%40thread.skype/conversations?groupId=913bf356-a280-4dcd-a9aa-0183d57e1c15&tenantId=72f988bf-86f1-41af-91ab-2d7cd011db47) or email us at [pop-sfbsupport@microsoft.com](mailto:pop-sfbsupport@microsoft.com)


 data