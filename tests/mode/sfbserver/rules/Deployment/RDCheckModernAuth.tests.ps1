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
# Filename: RDCheckModernAuth.tests.ps1
# Description: <TODO>
# Owner: <Unknown> <mmcintyr@microsoft.com>
# Created On: 5/19/2021 3:55 PM
#
#################################################################################
Set-StrictMode -Version Latest

$sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
$srcRoot  = "$root\src"
$testRoot = "$root\tests"
$testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
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
#. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDModernAuthMismatch.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDNotOAuthServers.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDUnableToGetOAuthConfiguration.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDLegacyModernAuthDetected.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDSIPHostingProviderNotEnabled.ps1)
. (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

. $sut

Describe -Tag 'SfBServer','Rule' "RDCheckModernAuth" {
	Context "RDCheckModernAuth" {
		BeforeEach {
			Mock Write-OPDEventLog {}

			$rule = [RDCheckModernAuth]::new([IDLegacyModernAuthDetected]::new())

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
					}
				)
			}

            Mock Get-Command { Get-CsOauthConfiguration }
		}

		It "Hybrid authentication found (IDLegacyModernAuthDetected)" {
            Mock Get-Command { 'Get-CsOauthConfiguration' }

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDLegacyModernAuthDetected'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDLegacyModernAuthDetected'
		}

		It "Legacy Modern authentication found (IDLegacyModernAuthDetected)" {

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDLegacyModernAuthDetected'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDLegacyModernAuthDetected'
		}

		#It "No OAuth servers found (IDNotOAuthServers)" {
		#	Mock Get-CsOAuthConfiguration {
		#		@(
		#			@{
		#				ServiceName                            = '00000004-0000-0ff1-ce00-000000000000'
		#				ClientAuthorizationOAuthServerIdentity = 'evoSTS'
  #                      OAuthServers = $null
		#			}
		#		)
		#	}
  #          Mock Get-Command { Get-CsOauthConfiguration }

  #          $rule.Execute($null)

  #          $rule.Success           | Should -BeFalse
  #          $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
  #          $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDNotOAuthServers'
  #          $rule.Insight.Action    | Should -Be $global:InsightActions.'IDNotOAuthServers'
		#}

		It "Unable to get OAuth configuration information (IDUnableToGetOAuthConfiguration)" {
			Mock Get-CsOAuthConfiguration {}
            Mock Get-Command { Get-CsOauthConfiguration }

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToGetOAuthConfiguration'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDUnableToGetOAuthConfiguration'
		}

  #      It "Detected mismatch condition #1 (IDModernAuthMismatch)" {
  #          Mock Get-CsHostingProvider {
  #              @(
  #                  @{
  #                      Identity                  = 'Skype For Business Online'
  #                      Name                      = 'Skype For Business Online'
  #                      ProxyFqdn                 = 'sipfed.online.lync.com'
  #                      VerificationLevel         = 'UseSourceVerification'
  #                      Enabled                   = $true
  #                      EnabledSharedAddressSpace = $true
  #                      HostsOCSUsers             = $true
  #                      IsLocal                   = $false
  #                      AutodiscoverUrl           = 'https://webdir1e.online.lync.com/Autodiscover/AutodiscoverService.svc/root'
  #                  }
  #              )
  #          }

  #          $rule.Execute($null)

  #          $rule.Success           | Should -BeFalse
  #          $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
  #          $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDModernAuthMismatch'
  #          $rule.Insight.Action    | Should -Be $global:InsightActions.'IDModernAuthMismatch'
		#}

  #      It "Detected mismatch condition #2 (IDModernAuthMismatch)" {
		#	Mock Get-CsOAuthConfiguration {
		#		@(
		#			@{
		#				ServiceName                            = '00000004-0000-0ff1-ce00-000000000000'
		#				ClientAuthorizationOAuthServerIdentity = 'evoSTS'
  #                      OAuthServers = @(
		#					@{
		#						Name                                = 'microsoft.sts'
		#						IssuerIdentifier                    = '00000001-0000-0000-c000-000000000000'
		#						Realm                               = 'eb7a032f-4ef2-4837-a1e8-df024977c231'
		#						MetadataUrl                         = 'https://accounts.accesscontrol.windows.net/eb7a032f-4ef2-4837-a1e8-df024977c231/metadata/json/1'
		#						Type                                = 'Acs'
		#						AcceptSecurityIdentifierInformation = $false
		#					},
  #                          @{
  #                              Name                                = 'evoSTS'
  #                              IssuerIdentifier                    = 'sts.windows.net'
  #                              MetadataUrl                         = 'https://login.windows.net/common/FederationMetadata/2007-06/FederationMetadata.xml'
  #                              Type                                = 'AzureAd'
  #                              AcceptSecurityIdentifierInformation = $true
  #                          }
  #                      )
		#			}
		#		)
		#	}

  #          Mock Get-CsHostingProvider {
  #              @(
  #                  @{
  #                      Identity                  = 'Skype For Business Online'
  #                      Name                      = 'Skype For Business Online'
  #                      ProxyFqdn                 = 'sipfed.online.lync.com'
  #                      VerificationLevel         = 'UseSourceVerification'
  #                      Enabled                   = $true
  #                      EnabledSharedAddressSpace = $false
  #                      HostsOCSUsers             = $true
  #                      IsLocal                   = $false
  #                      AutodiscoverUrl           = 'https://webdir1e.online.lync.com/Autodiscover/AutodiscoverService.svc/root'
  #                  }
  #              )
  #          }

  #          $rule.Execute($null)

  #          $rule.Success           | Should -BeFalse
  #          $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
  #          $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDModernAuthMismatch'
  #          $rule.Insight.Action    | Should -Be $global:InsightActions.'IDModernAuthMismatch'
		#}

	}
}