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
# Filename: RDCheckSQLLogs.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/19/2021 12:20 PM
#
# Last Modified On: 1/19/2021 12:22 PM
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
. (Join-Path $testRoot -ChildPath "testhelpers\LoadResourceFiles.ps1")

Import-ResourceFiles -Root $srcRoot -MyMode $mode

. (Join-Path $srcRoot  -ChildPath "common\Globals.ps1")
. (Join-Path $srcRoot  -ChildPath "common\Utils.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\common\Globals.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\common\$mode.ps1")
. (Join-Path $srcRoot  -ChildPath "classes\RuleDefinition.ps1")
. (Join-Path $srcRoot  -ChildPath "classes\InsightDefinition.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDLogSpaceThreshold.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDNoLogSpace.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDTestCsDatabaseNoResults.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDUnableToResolveServerFQDN.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDUnableToResolveDNSName.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDUnableToGetServiceInfo.ps1")

. (Join-Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

. $sut

Describe -Tag 'SfBServer' "RDCheckSQLLogs" {
	Context "RDCheckSQLLogs" {
		BeforeAll {
			Mock Write-OPDEventLog {}
		}

		BeforeEach {
			Mock Resolve-DnsName {
				@(
					@{
						Address    = "192.168.0.1"
						IPAddress  = "192.168.0.1"
						QueryType  = "A"
						IP4Address = "192.168.0.1"
						Name       = "sfbserver.contoso.com"
						Type       = "A"
					}
				)
			}

			Mock Get-CsComputer {
				@(
					@{
						Identity = "sfbserver.contoso.com"
						Pool     = "sfbserver.contoso.com"
						Fqdn     = "sfbserver.contoso.com"
					}
				)
			}

			Mock Get-CsService {
				@(
					@{
						Role         = "UserServer"
						Identity     = "UserServer:sfbserver.contoso.com"
						UserDatabase = "UserDatabase:sfbserver.contoso.com"
					}
				)
			}

			Mock Test-CsDatabase {
				@(
					@{
						SqlServerFqdn            = "sfbserver.contoso.com"
						SqlInstanceName          = "rtc"
						DatabaseName             = "rtcxds"
						DatabaseHighAvailability = "None"
						DataSource               = "sfbserver.contoso.com\rtc"
						SQLServerVersion         = "13.0.4259 SP1 Enterprise Edition (64-bit)"
						ExpectedVersion          = "15.13.21"
						InstalledVersion         = "15.13.21"
						Succeed                  = $true
					}
				)
			}

			Mock Invoke-SqlCmd {
				@(
					@{
						"Database Name"      = "rtcxds"
						"Log Size (MB)"      = 3999.992
						"Log Space Used (%)" = 1.655667
					}
				)
			}

			$rd = [RDCheckSQLLogs]::new([IDUnableToResolveDNSName]::new())
		}

		It "Runs with no errors (SUCCESS)" {
			$rd.Execute($null)
            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
		}

		It "Unable to resolve DNS name (IDUnableToResolveDNSName)" {
			Mock Resolve-DnsName {}

			$rd.Execute($null)
            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
			$rd.Insight.Name      | Should -Be 'IDUnableToResolveDNSName'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
		}

		It "Unable to resolve Server FQDN (IDUnableToResolveServerFQDN)" {
			Mock Resolve-DnsName {
				@(
					@{
						Address    = "192.168.0.1"
						IPAddress  = "192.168.0.1"
						QueryType  = "A"
						IP4Address = "192.168.0.1"
						Name       = [string]::Empty
						Type       = "A"
					}
				)
			}

			$rd.Execute($null)
            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
			$rd.Insight.Name      | Should -Be 'IDUnableToResolveServerFQDN'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
		}

		It "Unable to get Pool FQDN (IDUnableToGetServiceInfo)" {
			Mock Get-CsComputer {}

			$rd.Execute($null)
            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
			$rd.Insight.Name      | Should -Be 'IDUnableToGetServiceInfo'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
		}

		It "Unable to get remote database information (IDTestCsDatabaseNoResults)" {
			Mock Test-CsDatabase {}

			$rd.Execute($null)
            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
			$rd.Insight.Name      | Should -Be 'IDTestCsDatabaseNoResults'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
		}

		It "Unable to get log statistics (IDNoLogSpace)" {
			Mock Invoke-SqlCmd {}

			$remoteDatabase = Test-CsDatabase

			$rd.Execute($null)
            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
			$rd.Insight.Name      | Should -Be 'IDNoLogSpace'
            $rd.Insight.Detection | Should -Be ($global:InsightDetections.($rd.Insight.Name) -f $remoteDatabase.DataSource, $remoteDatabase.DatabaseName)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
		}


		It "SQL log space exceeds threshold value (IDLogSpaceThreshold)" {
			Mock Invoke-SqlCmd {
				@(
					@{
						"Database Name"      = "rtcxds"
						"Log Size (MB)"      = 3999.992
						"Log Space Used (%)" = 80.25
					}
				)
			}

			$remoteDatabase = Test-CsDatabase
			$logSpace       = Invoke-SqlCmd
			$logSpaceUsed   = ($logSpace | Where-Object {$_.'Database Name' -eq 'rtcxds'}).'Log Space Used (%)'

			$rd.Execute($null)
            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
			$rd.Insight.Name      | Should -Be 'IDLogSpaceThreshold'
            $rd.Insight.Detection | Should -Be ($global:InsightDetections.($rd.Insight.Name) -f $remoteDatabase.DataSource, `
												$remoteDatabase.DatabaseName, $global:SQLLogSpaceThreshold, $logSpaceUsed)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
		}
	}
}