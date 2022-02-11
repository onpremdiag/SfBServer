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
# Filename: RDCheckTenantModernAuthEnabled.tests (2).ps1
# Description: <TODO>
# Owner: <Unknown> <mmcintyr@microsoft.com>
# Created On: 4/14/2021 4:28 PM
#
#################################################################################
Set-StrictMode -Version Latest

$sut      = $PSCommandPath -replace '^(.*)\\tests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
$srcRoot  = "$root\src"
$testRoot = "$root\tests"
$testMode = $PSCommandPath -match "^(.*)\\tests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
$mode     = $Matches.Mode

Get-ChildItem -Path "$srcRoot\classes" -Recurse -Filter *.ps1 | ForEach-Object {. $_.FullName}

# Load resource files needed for tests
. (Join-Path -Path $testRoot -ChildPath testhelpers\LoadResourceFiles.ps1)

Import-ResourceFiles -Root $srcRoot -MyMode $mode

. (Join-Path -Path $srcRoot -ChildPath common\Globals.ps1)
. (Join-Path -Path $srcRoot -ChildPath common\Utils.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\Globals.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\$mode.ps1)
. (Join-Path -Path $srcRoot -ChildPath classes\RuleDefinition.ps1)
. (Join-Path -Path $srcRoot -ChildPath classes\InsightDefinition.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDNotOAuthServers.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDUnableToGetOAuthConfiguration.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDLegacyModernAuthDetected.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDSIPHostingProviderNotEnabled.ps1)
. (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

. $sut

Describe -Tag 'SfBServer','Rule' "RDCheckTenantModernAuthEnabled" {
	Context "RDCheckTenantModernAuthEnabled" {
		BeforeEach {
			Mock Write-OPDEventLog {}

			$rule = [RDCheckTenantModernAuthEnabled]::new([IDLegacyModernAuthDetected]::new())

			Mock Get-CsOAuthConfiguration {
				@(
					@{
						ServiceName                            = '00000004-0000-0ff1-ce00-000000000000'
						ClientAuthorizationOAuthServerIdentity = 'evoSTS'
                        OAuthServers = @(
							@{
								Name                                = 'microsoft.sts'
								IssuerIdentifier                    = '00000001-0000-0000-c000-000000000000'
								Realm                               = 'eb7a032f-4ef2-4837-a1e8-df024977c231'
								MetadataUrl                         = 'https://accounts.accesscontrol.windows.net/eb7a032f-4ef2-4837-a1e8-df024977c231/metadata/json/1'
								Type                                = 'Acs'
								AcceptSecurityIdentifierInformation = $false
							}
                        )
						ClientAdalAuthOverride = 'Allowed'
					}
				)
			}
		}

		It "Should be successful" {
			Mock Get-CsHostingProvider {
				@(
					@{
						Identity                  = 'OCO'
						Name                      = 'OCO'
						ProxyFqdn                 = 'sipfed.online.lync.com'
						VerificationLevel         = 'UseSourceVerification'
						Enabled                   = $true
						EnabledSharedAddressSpace = $true
						HostsOCSUsers             = $true
						IsLocal                   = $true
						AutodiscoverUrl           = [string]::Empty
					}
				)
			}

			$rule.Execute($null)

			$rule.Success           | Should -BeTrue
			$rule.EventId           | Should -Be $global:EventIds.($rule.Name)
		}

		It "Hybrid authentication found (IDDoNotAllowSharedSipAddressSpace)" {
			Mock Get-CsHostingProvider {}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDDoNotAllowSharedSipAddressSpace'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDDoNotAllowSharedSipAddressSpace'
		}

		It "ClientAdalAuthOverrid is not allowed (IDModernAuthSfboNotEnabled)" {
			Mock Get-CsHostingProvider {
				@(
					@{
						Identity                  = 'OCO'
						Name                      = 'OCO'
						ProxyFqdn                 = 'sipfed.online.lync.com'
						VerificationLevel         = 'UseSourceVerification'
						Enabled                   = $true
						EnabledSharedAddressSpace = $true
						HostsOCSUsers             = $true
						IsLocal                   = $true
						AutodiscoverUrl           = [string]::Empty
					}
				)
			}

			Mock Get-CsOAuthConfiguration {
				@(
					@{
						ServiceName                            = '00000004-0000-0ff1-ce00-000000000000'
						ClientAuthorizationOAuthServerIdentity = 'evoSTS'
                        OAuthServers = @(
							@{
								Name                                = 'microsoft.sts'
								IssuerIdentifier                    = '00000001-0000-0000-c000-000000000000'
								Realm                               = 'eb7a032f-4ef2-4837-a1e8-df024977c231'
								MetadataUrl                         = 'https://accounts.accesscontrol.windows.net/eb7a032f-4ef2-4837-a1e8-df024977c231/metadata/json/1'
								Type                                = 'Acs'
								AcceptSecurityIdentifierInformation = $false
							}
                        )
						ClientAdalAuthOverride = 'Disabled'
					}
				)
			}

            $oAuth = Get-CsOAuthConfiguration

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDModernAuthSfboNotEnabled' -f 'Allowed',$oAuth.ClientAdalAuthOverride)
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDModernAuthSfboNotEnabled'
		}

		It "Unable to get OAuth configuration information (IDUnableToGetOAuthConfiguration)" {
			Mock Get-CsOAuthConfiguration {}
			Mock Get-CsHostingProvider {
				@(
					@{
						Identity                  = 'OCO'
						Name                      = 'OCO'
						ProxyFqdn                 = 'sipfed.online.lync.com'
						VerificationLevel         = 'UseSourceVerification'
						Enabled                   = $true
						EnabledSharedAddressSpace = $true
						HostsOCSUsers             = $true
						IsLocal                   = $true
						AutodiscoverUrl           = [string]::Empty
					}
				)
			}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToGetOAuthConfiguration'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDUnableToGetOAuthConfiguration'
		}
	}
}