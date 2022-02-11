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
# Filename: RDCheckAddressInPool.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/28/2021 12:10 PM
#
# Last Modified On: 1/28/2021 12:11 PM
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
. (Join-Path $testRoot -ChildPath "testhelpers\LoadResourceFiles.ps1")

Import-ResourceFiles -Root $srcRoot -MyMode $mode

. (Join-Path $srcRoot  -ChildPath "common\Globals.ps1")
. (Join-Path $srcRoot  -ChildPath "common\Utils.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\common\Globals.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\common\$mode.ps1")
. (Join-Path $srcRoot  -ChildPath "classes\RuleDefinition.ps1")
. (Join-Path $srcRoot  -ChildPath "classes\InsightDefinition.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDIPAddressNotInPool.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDUnableToResolveDNSName.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDUnableToGetServiceInfo.ps1")

. (Join-Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

. $sut

Describe -Tag 'SfBServer' "RDCheckAddressInPool" {
	Context "RDCheckAddressInPool" {
		BeforeAll {
			Mock Write-OPDEventLog {}
		}

		BeforeEach {
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

			Mock Resolve-DnsName {
				@(
					@{
						Address    = "192.168.1.1"
						IPAddress  = "192.168.1.1"
						QueryType  = "A"
						IP4Address = "192.168.1.1"
						Name       = "pool.contoso.com"
						Type       = "A"
					},
					@{
						Address    = "192.168.1.2"
						IPAddress  = "192.168.1.2"
						QueryType  = "A"
						IP4Address = "192.168.1.2"
						Name       = "pool.contoso.com"
						Type       = "A"
					}
				)
			} -ParameterFilter {$Name -eq 'pool.contoso.com'}

			$rd = [RDCheckAddressInPool]::new([IDUnableToResolveDNSName]::new())
		}

		Mock Get-CsComputer {
			@(
				@{
					Identity = "pool.contoso.com"
					Pool     = "pool.contoso.com"
					Fqdn     = "pool.contoso.com"
				}
			)
		}

		It "Runs with no errors (SUCCESS)" {
			$rd.Execute($null)

            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
		}

		It "Unable to resolve local machine (IDUnableToResolveDNSName)" {
			Mock Resolve-DnsName { } -ParameterFilter {$Name -eq $env:COMPUTERNAME}

			$rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
			$rd.Insight.Name      | Should -Be 'IDUnableToResolveDNSName'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToResolveDNSName'
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDUnableToResolveDNSName'
		}

		It "Unable to get pool information (IDUnableToGetServiceInfo)" {
			Mock Get-CsComputer {}

			$rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
			$rd.Insight.Name      | Should -Be 'IDUnableToGetServiceInfo'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToGetServiceInfo'
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDUnableToGetServiceInfo'
		}

		It "Unable to get any pool ip addresses (IDNoPoolIPAddresses)" {
			Mock Get-CsComputer {
				@(
					@{
						Identity = "pool.contoso.com"
						Pool     = "pool.contoso.com"
						Fqdn     = "pool.contoso.com"
					}
				)
			}

			Mock Resolve-DnsName {} -ParameterFilter {$Name -eq 'pool.contoso.com'}

			$rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
			$rd.Insight.Name      | Should -Be 'IDNoPoolIPAddresses'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDNoPoolIPAddresses'
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDNoPoolIPAddresses'
		}

		It "Server IP address not in Pool IP list (IDIPAddressNotInPool)" {
			Mock Get-CsComputer {
				@(
					@{
						Identity = "pool.contoso.com"
						Pool     = "pool.contoso.com"
						Fqdn     = "pool.contoso.com"
					}
				)
			}

			Mock Resolve-DnsName {
                @(
                    @{
						Address    = "192.168.1.3"
						IPAddress  = "192.168.1.3"
						QueryType  = "A"
						IP4Address = "192.168.1.3"
						Name       = "fe1.ucstaff.com"
						Type       = "A"
                    }
                )
			} -ParameterFilter {$Name -eq $env:COMPUTERNAME}

			$ServerFqdn        = Resolve-DnsName -Name $env:COMPUTERNAME -Type A -ErrorAction SilentlyContinue
			$PoolFqdn          = Get-CsComputer -Identity $ServerFqdn.Name -ErrorAction SilentlyContinue
			$PoolIPAddressList = @(Resolve-DnsName -Name $PoolFqdn.Pool -Type A -ErrorAction SilentlyContinue)

			$rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
			$rd.Insight.Name      | Should -Be 'IDIPAddressNotInPool'
            $rd.Insight.Detection | Should -Be ($global:InsightDetections.'IDIPAddressNotInPool' -f $ServerFqdn.IpAddress, ($PoolIPAddressList -join ', '))
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDIPAddressNotInPool'
		}
	}
}