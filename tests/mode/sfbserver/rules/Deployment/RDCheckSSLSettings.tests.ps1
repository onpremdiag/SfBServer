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
# Filename: RDCheckSSLSettings.tests.ps1
# Description: <TODO>
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 11/23/2021 11:15 AM
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
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDSSLNotDisabled.ps1")
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDNotFEMachine.ps1")
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDRegistryKeyNotFound.ps1")
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDPropertyNotFoundException.ps1")
	. (Join-Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

	. $sut
}

Describe -Tag 'SfBServer' "RDCheckSSLSettings" {
	Context "Exists" {
		BeforeAll {
			Mock Write-OPDEventLog {}
			$OriginalComputerName = $env:COMPUTERNAME
			$OriginalDNSDomain    = $env:USERDNSDOMAIN
		}

		BeforeEach {
			$rule = [RDCheckSSLSettings]::new([IDSSLNotDisabled]::new())
			$env:ComputerName  = "FEServer"
            $env:USERDNSDOMAIN = "CONTOSO.COM"
		}

		AfterAll {
			$env:COMPUTERNAME  = $OriginalComputerName
			$env:USERDNSDOMAIN = $OriginalDNSDomain
		}


		It "Runs with no errors SSL 3.0/2.0 should be disabled (SUCCESS)" {
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
                        SSL = @(
                            @{
								SSLVersion              = '2.0'
								ServerEnabled           = $false
								ClientEnabled           = ([string]::Empty)
								ServerDisabledByDefault = $true
								ClientDisabledByDefault = ([string]::Empty)
                            },
                            @{
								SSLVersion              = '3.0'
								ServerEnabled           = $false
								ClientEnabled           = ([string]::Empty)
								ServerDisabledByDefault = $true
								ClientDisabledByDefault = ([string]::Empty)
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

		It "Runs with no errors SSL 3.0 'DisabledByDefault' is false (FAILURE)" {
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
                        SSL = @(
                            @{
								SSLVersion              = '2.0'
								ServerEnabled           = $false
								ClientEnabled           = ([string]::Empty)
								ServerDisabledByDefault = $true
								ClientDisabledByDefault = ([string]::Empty)
                            },
                            @{
								SSLVersion              = '3.0'
								ServerEnabled           = $false
								ClientEnabled           = ([string]::Empty)
								ServerDisabledByDefault = $false
								ClientDisabledByDefault = ([string]::Empty)
                            }
                        )
					}
                )
			}

			$ssl30 = (Get-AllTlsSettingsFromRegistry).SSL | Where-Object {$_.SSLVersion -eq '3.0'}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDSSLNotDisabled' -f 'SSL 3.0', $ssl30.ServerDisabledByDefault, $ssl30.ServerEnabled)
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDSSLNotDisabled'
		}

		It "Runs with no errors SSL 3.0 'Enabled' is true (FAILURE)" {
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
                        SSL = @(
                            @{
								SSLVersion              = '2.0'
								ServerEnabled           = $false
								ClientEnabled           = ([string]::Empty)
								ServerDisabledByDefault = $true
								ClientDisabledByDefault = ([string]::Empty)
                            },
                            @{
								SSLVersion              = '3.0'
								ServerEnabled           = $true
								ClientEnabled           = ([string]::Empty)
								ServerDisabledByDefault = $true
								ClientDisabledByDefault = ([string]::Empty)
                            }
                        )
					}
                )
			}

			$ssl30 = (Get-AllTlsSettingsFromRegistry).SSL | Where-Object {$_.SSLVersion -eq '3.0'}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDSSLNotDisabled' -f 'SSL 3.0', $ssl30.ServerDisabledByDefault, $ssl30.ServerEnabled)
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDSSLNotDisabled'
		}

		It "Runs with no errors SSL 2.0 'DisabledByDefault' is false (FAILURE)" {
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
                        SSL = @(
                            @{
								SSLVersion              = '2.0'
								ServerEnabled           = $false
								ClientEnabled           = ([string]::Empty)
								ServerDisabledByDefault = $false
								ClientDisabledByDefault = ([string]::Empty)
                            },
                            @{
								SSLVersion              = '3.0'
								ServerEnabled           = $false
								ClientEnabled           = ([string]::Empty)
								ServerDisabledByDefault = $true
								ClientDisabledByDefault = ([string]::Empty)
                            }
                        )
					}
                )
			}

			$ssl20 = (Get-AllTlsSettingsFromRegistry).SSL | Where-Object {$_.SSLVersion -eq '2.0'}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDSSLNotDisabled' -f 'SSL 2.0', $ssl20.ServerDisabledByDefault, $ssl20.ServerEnabled)
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDSSLNotDisabled'
		}

		It "Runs with no errors SSL 2.0 'Enabled' is true (FAILURE)" {
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
                        SSL = @(
                            @{
								SSLVersion              = '2.0'
								ServerEnabled           = $true
								ClientEnabled           = ([string]::Empty)
								ServerDisabledByDefault = $true
								ClientDisabledByDefault = ([string]::Empty)
                            },
                            @{
								SSLVersion              = '3.0'
								ServerEnabled           = $false
								ClientEnabled           = ([string]::Empty)
								ServerDisabledByDefault = $true
								ClientDisabledByDefault = ([string]::Empty)
                            }
                        )
					}
                )
			}

			$ssl20 = (Get-AllTlsSettingsFromRegistry).SSL | Where-Object {$_.SSLVersion -eq '2.0'}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDSSLNotDisabled' -f 'SSL 2.0', $ssl20.ServerDisabledByDefault, $ssl20.ServerEnabled)
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDSSLNotDisabled'
		}
	}
}