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
# Filename: RDCheckSfbServerCertificateValid.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 4/6/2021 11:54 AM
#
# Last Modified On: 4/6/2021 11:54 AM
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
. "$testRoot\testhelpers\LoadResourceFiles.ps1"
Import-ResourceFiles -Root $srcRoot -MyMode $mode

. (Join-Path -Path $srcRoot -ChildPath "common\Globals.ps1")
. (Join-Path -Path $srcRoot -ChildPath "common\Utils.ps1")
. (Join-Path -Path $srcRoot -ChildPath "mode\$mode\common\Globals.ps1")
. (Join-Path -Path $srcRoot -ChildPath "mode\$mode\common\$mode.ps1")
. (Join-Path -Path $srcRoot -ChildPath "classes\RuleDefinition.ps1")
. (Join-Path -Path $srcRoot -ChildPath "classes\InsightDefinition.ps1")
. (Join-Path -Path $srcRoot -ChildPath "mode\$mode\insights\Services\IDNoValidCertificates.ps1")
. (Join-Path -Path $srcRoot -ChildPath "mode\$mode\insights\Services\IDFrontendFqdnCertNotOnSan.ps1")
. (Join-Path -Path $srcRoot -ChildPath "mode\$mode\insights\Services\IDPoolFqdnCertNotOnSan.ps1")
. (Join-Path -Path $srcRoot -ChildPath "mode\$mode\insights\Global\IDUnableToResolveDNSName.ps1")
. (Join-Path -Path $srcRoot -ChildPath "mode\$mode\insights\Deployment\IDUnableToResolveServerFQDN.ps1")
. (Join-Path -Path $srcRoot -ChildPath "mode\$mode\insights\Services\IDNullOrEmptyPoolFQDN.ps1")
. (Join-Path -Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

. $sut

Describe -Tag 'SfBServer', 'Rule' "RDCheckSfbServerCertificateValid" {
	Context "RDCheckSfbServerCertificateValid" {
		BeforeAll {
            Mock Write-OPDEventLog {}
		}

		BeforeEach {
			Mock Get-CsCertificate {
				@(
					@{
						Issuer             = "CN=ucstaff-DC-CA, DC=ucstaff, DC=com"
						NotAfter           = (Get-Date).AddYears(1)
						NotBefore          = (Get-Date).AddYears(-1)
						SerialNumber       = "2300000005C96B5B0E58E81568000000000005"
						Subject            = "CN=ucstaff.com"
						AlternativeNames   = {}
						Thumbprint         = "4AA3C098CC06277EB2B4A51EE6B955FEA6FD9A71"
						EffectiveDate      = (Get-date).AddYears(-1).AddMinutes(10)
						PreviousThumbprint = [string]::Empty
						UpdateTime         = [string]::Empty
						Use                = "Default"
						SourceScope        = "Global"
					}
				)
			}

			Mock Resolve-DnsName {
                @(
                    @{
						Address    = "192.168.1.1"
						IPAddress  = "192.168.1.1"
						QueryType  = "A"
						IP4Address = "192.168.1.1"
						Name       = "fe1.ucstaff.com"
						Type       = "A"
                    }
                )
			} -ParameterFilter {$Name -eq $env:COMPUTERNAME}

            Mock Get-CsComputer {
                @(
                    @{
                        Identity = "edge.contoso.com"
                        Pool     = "edge.contoso.com"
                        Fqdn     = "edge.contoso.com"
                    }
                )
            }

			Mock Test-SanOnCert { $true }
			$rule = [RDCheckSfbServerCertificateValid]::new([IDNoValidCertificates]::new())

		}

		It "Runs with no errors (SUCCESS)" {

			$rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "No default/valid certificates (IDNoValidCertificates)" {
			Mock Get-CsCertificate {
				@(
					@{
						Issuer             = "CN=ucstaff-DC-CA, DC=ucstaff, DC=com"
						NotAfter           = (Get-Date).AddYears(1)
						NotBefore          = (Get-Date).AddYears(-1)
						SerialNumber       = "2300000005C96B5B0E58E81568000000000005"
						Subject            = "CN=ucstaff.com"
						AlternativeNames   = {}
						Thumbprint         = "4AA3C098CC06277EB2B4A51EE6B955FEA6FD9A71"
						EffectiveDate      = (Get-date).AddYears(-1).AddMinutes(10)
						PreviousThumbprint = [string]::Empty
						UpdateTime         = [string]::Empty
						Use                = "Chaff"
						SourceScope        = "Global"
					}
				)
			}

			$rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "Unable to resolve DNS Name for server (IDUnableToResolveDNSName)" {
			Mock Resolve-DnsName { } -ParameterFilter {$Name -eq $env:COMPUTERNAME}

			$rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "Unable to resolve server FQDN (IDUnableToResolveServerFQDN)" {
			Mock Resolve-DnsName {
                @(
                    @{
						Address    = "192.168.1.1"
						IPAddress  = "192.168.1.1"
						QueryType  = "A"
						IP4Address = "192.168.1.1"
						Name       = [string]::Empty
						Type       = "A"
                    }
                )
			} -ParameterFilter {$Name -eq $env:COMPUTERNAME}

			$rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "Null of empty Pool FQDN (IDNullOrEmptyPoolFQDN)" {
            Mock Get-CsComputer {
                @(
                    @{
                        Identity = "edge.contoso.com"
                        Pool     = [string]::Empty
                        Fqdn     = "edge.contoso.com"
                    }
                )
            }

			$PoolFQDN = Get-CSComputer -Identity 'edge.contoso.com'

			$rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f 'edge.contoso.com')
            $rule.Insight.Action    | Should -Be ($global:InsightActions.($rule.Insight.Name) -f 'fe1.ucstaff.com')
		}

		It "No matching cert found for Front End server (IDFrontendFqdnCertNotOnSan)" {
			Mock Test-SanOnCert { $false } -ParameterFilter {$SAN -eq 'fe1.ucstaff.com'}

			$rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f 'edge.contoso.com')
            $rule.Insight.Action    | Should -Be ($global:InsightActions.($rule.Insight.Name) -f 'fe1.ucstaff.com')
		}

		It "No matching cert found for Pool server (IDPoolFqdnCertNotOnSan)" {
            Mock Test-SanOnCert { $true } -ParameterFilter {$SAN -eq 'fe1.ucstaff.com'}
			Mock Test-SanOnCert { $false } -ParameterFilter {$SAN -eq 'edge.contoso.com'}

			$rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f 'edge.contoso.com')
            $rule.Insight.Action    | Should -Be ($global:InsightActions.($rule.Insight.Name) -f 'fe1.ucstaff.com')
		}
	}
}