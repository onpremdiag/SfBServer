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
# Filename: RDCheckSupportedPatchLevel.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 6/13/2019 1:59 PM
#
# Last Modified On: 6/13/2019 1:59 PM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
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
    . "$srcRoot\mode\$mode\insights\Admin\IDFarmPatchLevelUnsupported.ps1"
    . "$testRoot\mocks\SharePointMocks.ps1"

    . $sut
}

Describe -Tag 'SharePoint' "2016 Patch Levels" {
    BeforeAll {
        Mock Write-OPDEventLog {}

        Mock Get-SPProduct {
            return @{
                PatchableUnitDisplayNames = @(
                    "Microsoft SharePoint Foundation 2016 Core"
                    "Microsoft SharePoint Foundation 2016 1033 Lang Pack"
                )
            }
        }
    }

    Context "Supported patch levels" {
        BeforeAll {
            Mock Get-SharePointVersion { return "SP2016" }

            Mock Get-PatchableUnits {
                return @{
                    Id = [Guid]"{10160000-1014-0000-1000-0000000FF1CE}"
                    LatestPatch = @{
                        Version = [System.Version]"16.0.4705.1002"
                    }
                }
            }

            $rd = [RDCheckSupportedPatchLevel]::new([IDFarmPatchLevelUnsupported]::new())
            $rd.Execute($null)
        }

        #It "Should succeed" {
        #    "0. Actual: [{0}]`r`nExpected: [{1}]" -f $rd.Success, $true | Write-Host
        #    $rd.Success | Should -BeTrue
        #}

        #It "Should have the default insight detection" {
        #    #"1. Actual: [{0}]`r`nExpected: [{1}]" -f $rd.Insight.Detection, $rd.Insight.Detection | Write-Host
        #    $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
        #}

        #It "Should have the default insight action" {
        #    #"2. Actual: [{0}]`r`nExpected: [{1}]" -f $rd.Insight.Action, $rd.Insight.Action | Write-Host
        #    $rd.Insight.Action | Should -Be $global:InsightActions.($rd.Insight.Name)
        #}

        It "Should have an event ID" {
            $rd.EventId | Should -Be $global:EventIDs.($rd.Name)
        }
    }

    Context "Unsupported patch levels" {
        BeforeAll {
            Mock Get-SharePointVersion { return "SP2016" }

            Mock Get-PatchableUnits {
                return @{
                    Id = [Guid]"{10160000-1014-0000-1000-0000000FF1CE}"
                    LatestPatch = @{
                        Version = [System.Version]"16.0.4498.1002"
                    }
                }
            }

            $rd = [RDCheckSupportedPatchLevel]::new([IDFarmPatchLevelUnsupported]::new())
            $rd.Execute($null)
        }

        #It "Should succeed" {
        #    "2.5. Actual: [{0}]`r`nExpected: [{1}]" -f $rd.Success, $false | Write-Host
        #    $rd.Success | Should -BeTrue
        #}

        #It "Should not have the default insight detection" {
        #    "3. Actual: [{0}]`r`nExpected: [{1}]" -f $rd.Insight.Detection, $rd.Insight.Detection | Write-Host
        #    $rd.Insight.Detection | Should Not Be $global:InsightDetections.($rd.Insight.Name)
        #}

        #It "Should not have the default insight action" {
        #    "4. Actual: [{0}]`r`nExpected: [{1}]" -f $rd.Insight.Action, $rd.Insight.Action | Write-Host
        #    $rd.Insight.Action | Should Not Be $global:InsightActions.($rd.Insight.Name)
        #}

        It "Should have an event ID" {
            $rd.EventId | Should -Be $global:EventIDs.($rd.Name)
        }
    }
}

Describe -Tag 'SharePoint' "2013 Patch Levels" {
    BeforeAll {
        Mock Write-OPDEventLog {}

        Mock Get-SPProduct {
            return @{
                PatchableUnitDisplayNames = @(
                    "Microsoft SharePoint Foundation 2013 Core"
                    "Microsoft SharePoint Foundation 2013 1033 Lang Pack"
                )
            }
        }
    }

    Context "Supported patch levels" {
        BeforeAll {
            Mock Get-SharePointVersion { return "SP2013" }

            Mock Get-PatchableUnits {
                return @{
                    Id = [Guid]"{90150000-1014-0000-1000-0000000FF1CE}"
                    LatestPatch = @{
                        Version = [System.Version]"15.0.5023.1000"
                    }
                }
            }

            $rd = [RDCheckSupportedPatchLevel]::new([IDFarmPatchLevelUnsupported]::new())
            $rd.Execute($null)
        }

        #It "Should succeed" {
        #    "4.5. Actual: [{0}]`r`nExpected: [{1}]" -f $rd.Success, $true | Write-Host
        #    $rd.Success | Should -BeTrue
        #}

        #It "Should have the default insight detection" {
        #    #"5. Actual: [{0}]`r`nExpected: [{1}]" -f $rd.Insight.Detection, $rd.Insight.Detection | Write-Host
        #    $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
        #}

        #It "Should have the default insight action" {
        #    #"6. Actual: [{0}]`r`nExpected: [{1}]" -f $rd.Insight.Detection, $rd.Insight.Detection | Write-Host
        #    $rd.Insight.Action | Should -Be $global:InsightActions.($rd.Insight.Name)
        #}

        It "Should have an event ID" {
            $rd.EventId | Should -Be $global:EventIDs.($rd.Name)
        }
    }

    Context "Unsupported patch levels" {
        BeforeAll {
            Mock Get-SharePointVersion { return "SP2013" }

            Mock Get-PatchableUnits {
                return @{
                    Id = [Guid]"{90150000-1014-0000-1000-0000000FF1CE}"
                    LatestPatch = @{
                        Version = [System.Version]"15.0.4498.1002"
                    }
                }
            }

            $rd = [RDCheckSupportedPatchLevel]::new([IDFarmPatchLevelUnsupported]::new())
            $rd.Execute($null)
        }

        #It "Should succeed" {
        #    "6.5 Actual: [{0}]`r`nExpected: [{1}]" -f $rd.Success, $false | Write-Host
        #    $rd.Success | Should -BeTrue
        #}

        #It "Should not have the default insight detection" {
        #    "7. Actual: [{0}]`r`nExpected: [{1}]" -f $rd.Insight.Detection, $rd.Insight.Detection | Write-Host
        #    $rd.Insight.Detection | Should Not Be $global:InsightDetections.($rd.Insight.Name)
        #}

        #It "Should not have the default insight action" {
        #    "8. Actual: [{0}]`r`nExpected: [{1}]" -f $rd.Insight.Detection, $rd.Insight.Detection | Write-Host
        #    $rd.Insight.Action | Should Not Be $global:InsightActions.($rd.Insight.Name)
        #}

        It "Should have an event ID" {
            $rd.EventId | Should -Be $global:EventIDs.($rd.Name)
        }
    }
}