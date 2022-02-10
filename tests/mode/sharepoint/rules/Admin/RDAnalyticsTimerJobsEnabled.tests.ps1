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
# Filename: RDAnalyticsTimerJobsEnabled.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 6/20/2019 1:23 PM
#
# Last Modified On: 6/20/2019 1:23 PM
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
. "$srcRoot\mode\$mode\insights\Admin\IDAnalyticsTimerJobsNotEnabled.ps1"
. "$testRoot\mocks\SharePointMocks.ps1"

. $sut

Describe -Tag 'SharePoint' "RDAnalyticsTimerJobsEnabled" {
    Context "RDAnalyticsTimerJobsEnabled" {
        BeforeEach {
            Mock Write-OPDEventLog {}
            $rd = [RDAnalyticsTimerJobsEnabled]::new([IDAnalyticsTimerJobsNotEnabled]::new())
        }

        It "All timer jobs are enabled" {
            Mock Get-SPTimerJob {
                @(
                    @{
                        DisplayName = "Microsoft SharePoint Foundation Usage Data Import"
                        IsDisabled  = $false
                    },
                    @{
                        DisplayName = "Microsoft SharePoint Foundation Usage Data Maintenance"
                        IsDisabled  = $false
                    },
                    @{
                        DisplayName = "Microsoft SharePoint Foundation Usage Data Processing"
                        IsDisabled  = $false
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeTrue
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "Found a disabled timer job" {
            Mock Get-SPTimerJob {
                @(
                    @{
                        DisplayName = "Microsoft SharePoint Foundation Usage Data Processing"
                        IsDisabled  = $true
                    }
                )
            }

            $tj = Get-SPTimerJob

            $rd.Execute($null)
            $rd.Success           | Should -BeTrue
            $rd.Insight.Detection | Should -Be ($global:InsightDetections.($rd.Insight.Name) -f $tj.DisplayName)
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be ($global:InsightActions.($rd.Insight.Name) -f $tj.DisplayName)
        }
    }
}