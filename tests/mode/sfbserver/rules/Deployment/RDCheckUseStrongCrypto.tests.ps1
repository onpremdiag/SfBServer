﻿################################################################################
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
# Filename: RDCheckUseStrongCrypto.tests.ps1
# Description: <TODO>
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 12/14/2021 10:27 AM
#
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
	$sut                   = $PSCommandPath -replace '^(.*)\\tests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
	$root                  = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
	$srcRoot               = "$root\src"
	$testRoot              = "$root\tests"
	$testMode              = $PSCommandPath -match "^(.*)\\tests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
	$mode                  = $Matches.Mode
	$webConfigWithProxy    = Join-Path -Path (Split-Path -Path $PSCommandPath -Parent) -ChildPath 'WithProxy.web.config'
	$webConfigWithoutProxy = Join-Path -Path (Split-Path -Path $PSCommandPath -Parent) -ChildPath 'WithoutProxy.web.config'

	Get-ChildItem -Path "$srcRoot\classes" -Recurse -Filter *.ps1 | ForEach-Object {. $_.FullName}

	# Load resource files needed for tests
	. (Join-Path $testRoot -ChildPath "testhelpers\LoadResourceFiles.ps1")

	Import-ResourceFiles -Root $srcRoot -MyMode $mode

	. (Join-Path $srcRoot  -ChildPath "common\Globals.ps1")
	. (Join-Path $srcRoot  -ChildPath "common\Utils.ps1")
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\common\Globals.ps1")
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\common\$mode.ps1")
	. (Join-Path $srcRoot  -ChildPath "classes\RuleDefinition.ps1")
	. (Join-Path $srcRoot  -ChildPath "classes\InsightDefinition.ps1")
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDStrongCryptoNotSet.ps1")
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDNotFEMachine.ps1")
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDRegistryKeyNotFound.ps1")
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDPropertyNotFoundException.ps1")
	. (Join-Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

	. $sut
}

Describe -Tag 'SfBServer' "RDCheckUseStrongCrypto" {
	Context "RDCheckUseStrongCrypto" {
		BeforeAll {
			Mock Write-OPDEventLog {}
			$OriginalComputerName = $env:COMPUTERNAME
			$OriginalDNSDomain    = $env:USERDNSDOMAIN
		}

		BeforeEach {
			$rule = [RDCheckUseStrongCrypto]::new([IDStrongCryptoNotSet]::new())
			$env:ComputerName  = "FEServer"
            $env:USERDNSDOMAIN = "CONTOSO.COM"
		}

		AfterAll {
			$env:COMPUTERNAME  = $OriginalComputerName
			$env:USERDNSDOMAIN = $OriginalDNSDomain
		}

		It "Runs with no errors" {
			Mock Get-CsPool {
				@(
					@{
						Identity = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Fqdn     = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Services = @('Registrar:FEServer.contoso.com','UserServer:FEServer.contoso.com','ApplicationServer:FEServer.contoso.com')
						Computers = @($env:ComputerName + '.' + $env:USERDNSDOMAIN, 'Server1.contoso.com', 'Server2.contoso.com')
					}
				)
			}

			Mock Get-AllTlsSettingsFromRegistry {
                @(
					@{
                        Net = @(
                            @{
								NetVersion                  = 'v2.0.50727'
								SystemDefaultTlsVersions    = $false
								SchUseStrongCrypto          = $true
								WowSystemDefaultTlsVersions = $false
								WowSchUseStrongCrypto       = $true
                            },
                            @{
								NetVersion                  = 'v4.0.30319'
								SystemDefaultTlsVersions    = $false
								SchUseStrongCrypto          = $true
								WowSystemDefaultTlsVersions = $false
								WowSchUseStrongCrypto       = $true
                            }
                        )
					}
                )
			}

			$rule.Execute($null)
            $rule.Success           | Should -BeTrue
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "It should fail with IDWowStrongCryptoNotSet for .NET Framework v2.0.50727" {
			Mock Get-CsPool {
				@(
					@{
						Identity = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Fqdn     = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Services = @('Registrar:FEServer.contoso.com','UserServer:FEServer.contoso.com','ApplicationServer:FEServer.contoso.com')
						Computers = @($env:ComputerName + '.' + $env:USERDNSDOMAIN, 'Server1.contoso.com', 'Server2.contoso.com')
					}
				)
			}

			Mock Get-AllTlsSettingsFromRegistry {
                @(
					@{
                        Net = @(
                            @{
								NetVersion                  = 'v2.0.50727'
								SystemDefaultTlsVersions    = $false
								SchUseStrongCrypto          = $true
								WowSystemDefaultTlsVersions = $false
								WowSchUseStrongCrypto       = $false
                            },
                            @{
								NetVersion                  = 'v4.0.30319'
								SystemDefaultTlsVersions    = $false
								SchUseStrongCrypto          = $true
								WowSystemDefaultTlsVersions = $false
								WowSchUseStrongCrypto       = $true
                            }
                        )
					}
                )
			}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f 'v2.0.50727', 1, [int]$false)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "It should fail with IDStrongCryptoNotSet for .NET Framework v2.0.50727" {
			Mock Get-CsPool {
				@(
					@{
						Identity = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Fqdn     = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Services = @('Registrar:FEServer.contoso.com','UserServer:FEServer.contoso.com','ApplicationServer:FEServer.contoso.com')
						Computers = @($env:ComputerName + '.' + $env:USERDNSDOMAIN, 'Server1.contoso.com', 'Server2.contoso.com')
					}
				)
			}

			Mock Get-AllTlsSettingsFromRegistry {
                @(
					@{
                        Net = @(
                            @{
								NetVersion                  = 'v2.0.50727'
								SystemDefaultTlsVersions    = $false
								SchUseStrongCrypto          = $false
								WowSystemDefaultTlsVersions = $false
								WowSchUseStrongCrypto       = $true
                            },
                            @{
								NetVersion                  = 'v4.0.30319'
								SystemDefaultTlsVersions    = $false
								SchUseStrongCrypto          = $true
								WowSystemDefaultTlsVersions = $false
								WowSchUseStrongCrypto       = $true
                            }
                        )
					}
                )
			}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f 'v2.0.50727', 1, [int]$false)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "It should fail with IDWowStrongCryptoNotSet for .NET Framework v4.0.30319" {
			Mock Get-CsPool {
				@(
					@{
						Identity = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Fqdn     = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Services = @('Registrar:FEServer.contoso.com','UserServer:FEServer.contoso.com','ApplicationServer:FEServer.contoso.com')
						Computers = @($env:ComputerName + '.' + $env:USERDNSDOMAIN, 'Server1.contoso.com', 'Server2.contoso.com')
					}
				)
			}

			Mock Get-AllTlsSettingsFromRegistry {
                @(
					@{
                        Net = @(
                            @{
								NetVersion                  = 'v2.0.50727'
								SchUseStrongCrypto          = $true
								WowSchUseStrongCrypto       = $true
                            },
                            @{
								NetVersion                  = 'v4.0.30319'
								SchUseStrongCrypto          = $true
								WowSchUseStrongCrypto       = $false
                            }
                        )
					}
                )
			}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f 'v4.0.30319', 1, [int]$false)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "It should fail with IDStrongCryptoNotSet for .NET Framework v4.0.30319" {
			Mock Get-CsPool {
				@(
					@{
						Identity = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Fqdn     = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Services = @('Registrar:FEServer.contoso.com','UserServer:FEServer.contoso.com','ApplicationServer:FEServer.contoso.com')
						Computers = @($env:ComputerName + '.' + $env:USERDNSDOMAIN, 'Server1.contoso.com', 'Server2.contoso.com')
					}
				)
			}

			Mock Get-AllTlsSettingsFromRegistry {
                @(
					@{
                        Net = @(
                            @{
								NetVersion                  = 'v2.0.50727'
								SchUseStrongCrypto          = $true
								WowSchUseStrongCrypto       = $true
                            },
                            @{
								NetVersion                  = 'v4.0.30319'
								SchUseStrongCrypto          = $false
								WowSchUseStrongCrypto       = $true
                            }
                        )
					}
                )
			}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f 'v4.0.30319', 1, [int]$false)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}
	}
}