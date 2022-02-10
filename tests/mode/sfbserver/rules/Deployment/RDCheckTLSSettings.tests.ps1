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
# Filename: RDCheckTLSSettings.tests.ps1
# Description: <TODO>
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 11/18/2021 4:20 PM
#
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
	$sut                   = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
	$root                  = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
	$srcRoot               = "$root\src"
	$testRoot              = "$root\OnPremDiagTests"
	$testMode              = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
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
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDTLSNotEnabled.ps1")
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDNotFEMachine.ps1")
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDRegistryKeyNotFound.ps1")
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDPropertyNotFoundException.ps1")
	. (Join-Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

	. $sut
}

Describe -Tag 'SfBServer' "RDCheckTLSSettings" {
	Context "RDCheckTLSSettings" {
		BeforeAll {
			Mock Write-OPDEventLog {}
			$OriginalComputerName = $env:COMPUTERNAME
			$OriginalDNSDomain    = $env:USERDNSDOMAIN
		}

		BeforeEach {
			$rule = [RDCheckTLSSettings]::new([IDTLSNotEnabled]::new())
			$env:ComputerName  = "FEServer"
            $env:USERDNSDOMAIN = "CONTOSO.COM"
		}

		AfterAll {
			$env:COMPUTERNAME  = $OriginalComputerName
			$env:USERDNSDOMAIN = $OriginalDNSDomain
		}

		It "Runs with no errors TLS 1.2 should be enabled (SUCCESS)" {
			Mock Get-CsPool {
				@(
					@{
						Identity  = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Fqdn      = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Services  = @('Registrar:FEServer.contoso.com','UserServer:FEServer.contoso.com','ApplicationServer:FEServer.contoso.com')
						Computers = @($env:ComputerName + '.' + $env:USERDNSDOMAIN, 'Server1.contoso.com', 'Server2.contoso.com')
					}
				)
			}

			Mock Get-AllTlsSettingsFromRegistry {
                @(
					@{
                        TLS = @(
                            @{
						        TLSVersion              = '1.2'
						        ServerEnabled           = $true
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $false
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.1'
						        ServerEnabled           = $false
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $true
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.0'
						        ServerEnabled           = $false
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $true
						        ClientDisabledByDefault = [string]::Empty
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

		It "TLS 1.2 'DisabledByDefault' is true (FAILURE)" {
			Mock Get-CsPool {
				@(
					@{
						Identity  = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Fqdn      = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Services  = @('Registrar:FEServer.contoso.com','UserServer:FEServer.contoso.com','ApplicationServer:FEServer.contoso.com')
						Computers = @($env:ComputerName + '.' + $env:USERDNSDOMAIN, 'Server1.contoso.com', 'Server2.contoso.com')
					}
				)
			}

			Mock Get-AllTlsSettingsFromRegistry {
                @(
					@{
                        TLS = @(
                            @{
						        TLSVersion              = '1.2'
						        ServerEnabled           = [string]::Empty
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $true
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.1'
						        ServerEnabled           = [string]::Empty
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = [string]::Empty
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.0'
						        ServerEnabled           = [string]::Empty
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = [string]::Empty
						        ClientDisabledByDefault = [string]::Empty
                            }
                        )
					}
                )
			}

			$tls12 = (Get-AllTlsSettingsFromRegistry).Tls | Where-Object {$_.TLSVersion -eq '1.2'}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDTLSNotEnabled' -f 'TLS1.2', $tls12.ServerDisabledByDefault, $tls12.ServerEnabled)
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDTLSNotEnabled'
		}

		It "TLS 1.2 is 'Enabled' is false (FAILURE)" {
			Mock Get-CsPool {
				@(
					@{
						Identity  = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Fqdn      = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Services  = @('Registrar:FEServer.contoso.com','UserServer:FEServer.contoso.com','ApplicationServer:FEServer.contoso.com')
						Computers = @($env:ComputerName + '.' + $env:USERDNSDOMAIN, 'Server1.contoso.com', 'Server2.contoso.com')
					}
				)
			}

			Mock Get-AllTlsSettingsFromRegistry {
                @(
					@{
                        TLS = @(
                            @{
						        TLSVersion              = '1.2'
						        ServerEnabled           = $false
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $false
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.1'
						        ServerEnabled           = [string]::Empty
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = [string]::Empty
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.0'
						        ServerEnabled           = [string]::Empty
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = [string]::Empty
						        ClientDisabledByDefault = [string]::Empty
                            }
                        )
					}
                )
			}

			$tls12 = (Get-AllTlsSettingsFromRegistry).Tls | Where-Object {$_.TLSVersion -eq '1.2'}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDTLSNotEnabled' -f 'TLS1.2', $tls12.ServerDisabledByDefault, $tls12.ServerEnabled)
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDTLSNotEnabled'
		}

		It "TLS 1.1 is 'DisabledByDefault' is false (FAILURE)" {
			Mock Get-CsPool {
				@(
					@{
						Identity  = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Fqdn      = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Services  = @('Registrar:FEServer.contoso.com','UserServer:FEServer.contoso.com','ApplicationServer:FEServer.contoso.com')
						Computers = @($env:ComputerName + '.' + $env:USERDNSDOMAIN, 'Server1.contoso.com', 'Server2.contoso.com')
					}
				)
			}

			Mock Get-AllTlsSettingsFromRegistry {
                @(
					@{
                        TLS = @(
                            @{
						        TLSVersion              = '1.2'
						        ServerEnabled           = $true
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $false
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.1'
						        ServerEnabled           = [string]::Empty
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $false
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.0'
						        ServerEnabled           = [string]::Empty
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = [string]::Empty
						        ClientDisabledByDefault = [string]::Empty
                            }
                        )
					}
                )
			}

			$tls11 = (Get-AllTlsSettingsFromRegistry).Tls | Where-Object {$_.TLSVersion -eq '1.1'}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDTLSNotEnabled' -f 'TLS1.1', $tls11.ServerDisabledByDefault, $tls11.ServerEnabled)
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDTLSNotEnabled'
		}

		It "TLS 1.1 is 'Enabled' is true (FAILURE)" {
			Mock Get-CsPool {
				@(
					@{
						Identity  = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Fqdn      = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Services  = @('Registrar:FEServer.contoso.com','UserServer:FEServer.contoso.com','ApplicationServer:FEServer.contoso.com')
						Computers = @($env:ComputerName + '.' + $env:USERDNSDOMAIN, 'Server1.contoso.com', 'Server2.contoso.com')
					}
				)
			}

			Mock Get-AllTlsSettingsFromRegistry {
                @(
					@{
                        TLS = @(
                            @{
						        TLSVersion              = '1.2'
						        ServerEnabled           = $true
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $false
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.1'
						        ServerEnabled           = $true
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $true
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.0'
						        ServerEnabled           = [string]::Empty
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = [string]::Empty
						        ClientDisabledByDefault = [string]::Empty
                            }
                        )
					}
                )
			}

			$tls11 = (Get-AllTlsSettingsFromRegistry).Tls | Where-Object {$_.TLSVersion -eq '1.1'}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDTLSNotEnabled' -f 'TLS1.1', $tls11.ServerDisabledByDefault, $tls11.ServerEnabled)
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDTLSNotEnabled'
		}

		It "TLS 1.0 is 'DisabledByDefault' is false (FAILURE)" {
			Mock Get-CsPool {
				@(
					@{
						Identity  = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Fqdn      = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Services  = @('Registrar:FEServer.contoso.com','UserServer:FEServer.contoso.com','ApplicationServer:FEServer.contoso.com')
						Computers = @($env:ComputerName + '.' + $env:USERDNSDOMAIN, 'Server1.contoso.com', 'Server2.contoso.com')
					}
				)
			}

			Mock Get-AllTlsSettingsFromRegistry {
                @(
					@{
                        TLS = @(
                            @{
						        TLSVersion              = '1.2'
						        ServerEnabled           = $true
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $false
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.1'
						        ServerEnabled           = $false
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $true
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.0'
						        ServerEnabled           = [string]::Empty
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $false
						        ClientDisabledByDefault = [string]::Empty
                            }
                        )
					}
                )
			}

			$tls10 = (Get-AllTlsSettingsFromRegistry).Tls | Where-Object {$_.TLSVersion -eq '1.0'}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDTLSNotEnabled' -f 'TLS1.0', $tls10.ServerDisabledByDefault, $tls10.ServerEnabled)
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDTLSNotEnabled'
		}

		It "TLS 1.0 is 'Enabled' is true (FAILURE)" {
			Mock Get-CsPool {
				@(
					@{
						Identity  = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Fqdn      = $env:ComputerName + '.' + $env:USERDNSDOMAIN
						Services  = @('Registrar:FEServer.contoso.com','UserServer:FEServer.contoso.com','ApplicationServer:FEServer.contoso.com')
						Computers = @($env:ComputerName + '.' + $env:USERDNSDOMAIN, 'Server1.contoso.com', 'Server2.contoso.com')
					}
				)
			}

			Mock Get-AllTlsSettingsFromRegistry {
                @(
					@{
                        TLS = @(
                            @{
						        TLSVersion              = '1.2'
						        ServerEnabled           = $true
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $false
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.1'
						        ServerEnabled           = $false
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $true
						        ClientDisabledByDefault = [string]::Empty
                            },
                            @{
						        TLSVersion              = '1.0'
						        ServerEnabled           = $true
						        ClientEnabled           = [string]::Empty
						        ServerDisabledByDefault = $true
						        ClientDisabledByDefault = [string]::Empty
                            }
                        )
					}
                )
			}

			$tls10 = (Get-AllTlsSettingsFromRegistry).Tls | Where-Object {$_.TLSVersion -eq '1.0'}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDTLSNotEnabled' -f 'TLS1.0', $tls10.ServerDisabledByDefault, $tls10.ServerEnabled)
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDTLSNotEnabled'
		}

		It "No Front End Servers (FE) found (IDNotFEMachine)" {
			Mock Get-CsPool { return $null}

			$rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDNotFEMachine'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDNotFEMachine'
		}
	}
}