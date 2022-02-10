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
# Filename: RDCheckProfileServiceIsOnline.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 7/9/2019 1:27 PM
#
# Last Modified On: 7/9/2019 1:27 PM
#################################################################################
Set-StrictMode -Version Latest

$sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
$srcRoot  = "$root\src"
$testRoot = "$root\OnPremDiagTests"
$testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
$mode     = $Matches.Mode

# Load resource files needed for tests
. "$testRoot\testhelpers\LoadResourceFiles.ps1"
Import-ResourceFiles -Root $srcRoot -MyMode $mode

. "$srcRoot\common\Globals.ps1"
. "$srcRoot\common\Utils.ps1"
. "$srcRoot\mode\$mode\common\Globals.ps1"
. "$srcRoot\mode\$mode\common\$mode.ps1"
. "$srcRoot\classes\RuleDefinition.ps1"
. "$srcRoot\classes\InsightDefinition.ps1"
. "$srcRoot\mode\$mode\insights\Admin\IDNoUserProfileServiceInstances.ps1"
. "$testRoot\mocks\SharePointMocks.ps1"

. $sut

Describe -Tag 'SharePoint' "RDCheckProfileServiceIsOnline" {
    Context "RDCheckProfileServiceIsOnline" {

        BeforeEach {
            Mock Write-OPDEventLog {}
            $rd = [RDCheckProfileServiceIsOnline]::new([IDNoUserProfileServiceInstances]::new())
        }

        It "All UPS instances online" {
            Mock Get-SPServiceInstance {
                return @(
                    @{
                        Server   = "Server1"
                        TypeName = "User Profile Service"
                        Status   = "Online"
                        Id       = [System.Guid]::Empty
                    },
                    @{
                        Server   = "Server2"
                        TypeName = "User Profile Service"
                        Status   = "Online"
                        Id       = [System.Guid]::Empty
                    }
                )
            }

            $rd.Execute($null)
            $rd.Success           | Should -BeTrue
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "At least one UPS instances online" {
            Mock Get-SPServiceInstance {
                return @(
                    @{
                        Server   = "Server1"
                        TypeName = "User Profile Service"
                        Status   = "Offline"
                        Id       = [System.Guid]::Empty
                    },
                    @{
                        Server   = "Server2"
                        TypeName = "User Profile Service"
                        Status   = "Online"
                        Id       = [System.Guid]::Empty
                    }
                )
            }

            $rd.Execute($null)
            $rd.Success           | Should -BeTrue
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "No UPS instances online" {
            Mock Get-SPServiceInstance {
                return @(
                    @{
                        Server   = "Server1"
                        TypeName = "User Profile Service"
                        Status   = "Offline"
                        Id       = [System.Guid]::Empty
                    },
                    @{
                        Server   = "Server2"
                        TypeName = "User Profile Service"
                        Status   = "Offline"
                        Id       = [System.Guid]::Empty
                    }
                )
            }

            $rd.Execute($null)
            $rd.Success           | Should -BeTrue
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "No UPS instances found" {
            Mock Get-SPServiceInstance {
                return @(
                    @{
                        Server   = "Server1"
                        TypeName = "Microsoft SharePoint Foundation Workflow Timer Service"
                        Status   = "Online"
                        Id       = [System.Guid]::Empty
                    },
                    @{
                        Server   = "Server2"
                        TypeName = "Managed Metadata Web Service"
                        Status   = "Offline"
                        Id       = [System.Guid]::Empty
                    }
                )
            }

            $rd.Execute($null)
            $rd.Success           | Should -BeTrue
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }
	}
}