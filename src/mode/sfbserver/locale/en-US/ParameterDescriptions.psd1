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
# Filename: ParameterDescriptions.psd1
# Description: Localized parameter descriptions
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 3/1/2021 1:43 PM
#
# Last Modified On: 3/1/2021 1:44 PM
#################################################################################
ConvertFrom-StringData @'
###PSLOC
	PDDomainName             = Fully qualified domain name (FQDN)
	PDEdgePassword           = The password associated with your Skype for Business Edge server username
	PDEdgeUserID             = The admin username for the Skype for Business Edge
	PDExchangePassword       = The password associated with your Exchange account
	PDExchangeServer         = Fully qualified domain name (FQDN) of the Exchange server
	PDExchangeUserID         = The admin username for the Exchange server
	PDO365Domain             = The default domain that was included with your Office 365 subscription
	PDPromptExchangeAADCreds =
	PDPromptForAADCreds      =
	PDPromptforTeamsCreds    =
	PDRemoteFqdnDomain       = Fully qualified domain name (FQDN) of the federated domain
	PDSipAddress             = The SIP address for the account. Commonly the same as the UPN
	PDTenantPassword         = The password associated with your tenant admin account
	PDTenantUserID           = The admin account for your O365 tenant
###PSLOC
'@
