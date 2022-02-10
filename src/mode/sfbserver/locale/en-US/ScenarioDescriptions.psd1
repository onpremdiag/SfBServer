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
# Filename: ScenarioDescriptions.psd1
# Description: Localized scenario descriptions
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 3/1/2021 1:40 PM
#
# Last Modified On: 3/1/2021 1:44 PM
#################################################################################
ConvertFrom-StringData @'
###PSLOC
	SDBestPractices                          = Skype for Business Server deployment best practices analyzer
	SDCheckDatabasesVersions                 = Check if Skype for Business Server databases match expected version
	SDCheckSfbServerSupportability           = Skype for Business Server deployment best practices analyzer
	SDExchangeHybridIntegrationNotWorking    = Skype for Business Server and Exchange Hybrid deployment integration is not working
	SDExchangeIntegrationFailing             = Exchange integration is not working
	SDExchangeOnlineIntegrationNotWorking    = Skype for Business Server and Exchange Online integration is not working
	SDExchangeOnPremiseIntegrationNotWorking = Skype for Business Server and Exchange On-Premises deployment integration is not working
	SDHybridDeploymentProperlyDisabled       = Validates that the Skype for Business hybrid deployment is disabled
	SDHybridFederation                       = Federation is not working (Hybrid deployment)
	SDModernAuthenticationNotWorking         = Skype for Business Modern Authentication is not working
	SDOnPremFederation                       = Federation is not working (On-Premises deployment)
	SDPresenceAndIMDelay                     = Presence subscription and instant messaging delays
	SDPresenceIMNotWorking                   = IM and Presence problems between Skype for Business and Teams users
	SDResponseGroupUsageReport               = Check if response group usage report runs correctly
	SDSfbServerFrontendServiceNotStarting    = The front end service is not starting in Skype for Business Server
	SDSfbServerPSModuleLoadedAndIsFrontend   = Check to see if Skype for Business PowerShell module is loaded and local machine is Skype for Business Server frontend
	SDTLSDeprecation                         = Check to see if TLS 1.0/1.1 deprecation is properly configured
	SDUserContactCardPhoneNumberNotAvailable = User contact card phone number is missing
	SDUserContactListIsMissing               = User contact list is not available
'@
