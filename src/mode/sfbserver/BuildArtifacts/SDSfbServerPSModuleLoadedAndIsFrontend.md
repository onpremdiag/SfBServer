# Check to see if Skype for Business PowerShell module is loaded and local machine is Skype for Business Server frontend
**Owner:** [Owner of this document]

# Description

**[TODO]**

[[_TOC_]]

# Execution flow

::: mermaid
graph LR

Parameter1[\Parameter1\] -.-> Scenario(Scenario)
Parameter2[\Parameter2\] -.-> Scenario(Scenario)
Parameter3[\Parameter3\] -.-> Scenario(Scenario)
Scenario --> Analyzer1(Analyzer1)
Analyzer1 --> Rule1(Rule1)
Rule1 --> Insight1(Insight1)
Rule1 --> Insight2(Insight2)
Insight1 --> Detection(Detection)
Insight1 --> Action(Action)
Insight2 --> ...(...)
:::
___
::: mermaid
graph LR

%%
%% Scenario Name: SDSfbServerPSModuleLoadedAndIsFrontend
%% Date Generated: 11/30/2021 12:40:19 PM
%% This file is autogenerated. Please do not edit directly
%%


	SDSfbServerPSModuleLoadedAndIsFrontend(SDSfbServerPSModuleLoadedAndIsFrontend) --1--> ADIsSfbServerAdminAccount[ADIsSfbServerAdminAccount]

	ADIsSfbServerAdminAccount -- 1.1 --> RDCheckSfbServerAccountAdminRights[RDCheckSfbServerAccountAdminRights]
	SDSfbServerPSModuleLoadedAndIsFrontend --2 --> ADIsSfbServerFrontend[ADIsSfbServerFrontend]

	ADIsSfbServerFrontend -- 2.1 --> RDIsSfbServerFrontend[RDIsSfbServerFrontend]
	SDSfbServerPSModuleLoadedAndIsFrontend --3 --> ADIsTeamsModuleLoaded[ADIsTeamsModuleLoaded]

	ADIsTeamsModuleLoaded -- 3.1 --> RDTeamsModuleLoaded[RDTeamsModuleLoaded]
	SDSfbServerPSModuleLoadedAndIsFrontend --4 --> ADSfbServerPowerShellModuleLoaded[ADSfbServerPowerShellModuleLoaded]

	ADSfbServerPowerShellModuleLoaded -- 4.1 --> RDSfbServerPowerShellModuleLoaded[RDSfbServerPowerShellModuleLoaded]

:::


# Rule specifications
### R1 - RDCheckSfbServerAccountAdminRights 
- Determine if current account has Skype for Business Server administrative privileges
***[TODO:Rule specification goes here]***

### R2 - RDIsSfbServerFrontend 
- Determine if Skype for Business Frontend Server role is installed on local machine
***[TODO:Rule specification goes here]***

### R3 - RDSfbServerPowerShellModuleLoaded 
- Determine if this is a Skype for Business Server PowerShell module is loaded
***[TODO:Rule specification goes here]***

### R4 - RDTeamsModuleLoaded 
- Determine if the required version MicrosoftTeams module is loaded
***[TODO:Rule specification goes here]***



# Messages
When particular rule detects an issue (return value is false) an **Insight detection** 
and an **Insight Action** are displayed in addition to an **Analyzer message** and **Rule description**.
For more details, see example below:

(...)
- ***[TODO]***

(...)


### Scenario Description
| **Language** | **Name** | **Description** |
|:----------|:------|:-------------|
| en-US | SDSfbServerPSModuleLoadedAndIsFrontend | Check to see if Skype for Business PowerShell module is loaded and local machine is Skype for Business Server frontend




### Analyzer Descriptions
| **#** | **Language** | **Name** | **Description** | 
|:------|:----------|:------|:-------------|
| A1 | en-US | ADIsSfbServerAdminAccount | Verifies if account has Skype for Business Server administrative privileges|
| A2 | en-US | ADIsSfbServerFrontend | Verifies if Skype for Business Server frontend role is installed on this machine|
| A3 | en-US | ADIsTeamsModuleLoaded | Verifies that the minimum version MicrosoftTeams module is loaded|
| A4 | en-US | ADSfbServerPowerShellModuleLoaded | Verifies that the Skype for Business PowerShell module is loaded|


### Rule Descriptions
| **#** | **Language** | **Name** | **Description** | 
|:------|:---------|:-----|:------------|
| R1 | en-US | RDCheckSfbServerAccountAdminRights | Determine if current account has Skype for Business Server administrative privileges |
| R2 | en-US | RDIsSfbServerFrontend | Determine if Skype for Business Frontend Server role is installed on local machine |
| R3 | en-US | RDSfbServerPowerShellModuleLoaded | Determine if this is a Skype for Business Server PowerShell module is loaded |
| R4 | en-US | RDTeamsModuleLoaded | Determine if the required version MicrosoftTeams module is loaded |







