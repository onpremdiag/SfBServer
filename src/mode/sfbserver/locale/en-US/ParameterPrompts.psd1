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
# Filename: ParameterPrompts.psd1
# Description: Localized parameter prompts
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 3/1/2021 1:44 PM
#
# Last Modified On: 3/1/2021 1:44 PM
#################################################################################
#culture = "en-US"
ConvertFrom-StringData @'
###PSLOC
	PDDomainName             = Domain Name
	PDEdgePassword           = Skype for Business Edge server admin password
	PDEdgeUserID             = Skype for Business Edge server admin username
	PDExchangePassword       = Exchange server admin password
	PDExchangeServer         = Exchange server name
	PDExchangeUserID         = Exchange server admin username
	PDO365Domain             = Office 365 default domain
	PDPromptExchangeAADCreds = Next you will be prompted for Exchange admin credentials followed by Azure AD admin credentials prompt. Please press Enter to continue
	PDPromptForAADCreds      = Next you will be prompted for Azure AD admin credentials. Please press Enter to continue
	PDPromptforTeamsCreds    = Next you will be prompted for Teams Administrator/Global Administrator credentials. Please press Enter to continue
	PDRemoteFqdnDomain       = Remote federated domain (FQDN)
	PDSipAddress             = User SIP Address
	PDTenantPassword         = Office 365 tenant admin password
	PDTenantUserID           = Office 365 tenant admin username
###PSLOC
'@

