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
# Filename: RDPatchVersion.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 12/9/2020 10:59 AM
#
# Last Modified On: 12/9/2020 10:59 AM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
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
    . (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDPatchUpdateAvailable.ps1")
    . (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDUnableToGetProductName.ps1")
    . (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDUnableToGetVersion.ps1")
    . (Join-Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

    . $sut
}

Describe  -Tag 'SfBServer' "RDCheckPatchVersion" {
    Context "RDCheckPatchVersion" {
        BeforeAll {
            Mock Write-OPDEventLog {}
        }

        BeforeEach {
            $rd = [RDCheckPatchVersion]::new([IDUnableToGetVersion]::new())
        }

        It "Runs with no errors (SUCCESS)" {
            Mock Get-CsServerVersion { "Skype for Business Server 2019 (7.0.2046.0): Volume license key installed." }
            Mock Get-CsServerPatchVersion {
                @(
                    @{
                        ComponentName = "Skype for Business Server 2019, Core Components"
                        Version = "7.0.2046.396"
                    },
                    @{
                        ComponentName = "Skype for Business Server 2019, Core Management Server"
                        Version = "7.0.2046.123"
                    }
                )
            }

            $rd.Execute($null)
            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "Unable to determine product version (IDUnableToGetVersion)" {
            Mock Get-CsServerVersion {}

            $rd.Execute($null)
            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToGetVersion'
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDUnableToGetVersion'

        }

        It "Unable to find matching product (IDUnableToGetProductName)" {
            Mock Get-CsServerVersion { "Skype for Business Server 2014 (5.0.2046.0): Volume license key installed." }

            $rd.Execute($null)
            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToGetProductName'
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDUnableToGetProductName'
        }

        It "Update is available (IDPatchUpdateAvailable)" {
            Mock Get-CsServerVersion { "Skype for Business Server 2019 (7.0.2046.0): Volume license key installed." }
            Mock Get-CsServerPatchVersion {
                @(
                    @{
                        ComponentName = "Skype for Business Server 2019, Core Components"
                        Version = "7.0.2046.244"
                    }
                )
            }

            $CurrentProduct  = Get-CsServerVersion
            $ProductName     = $global:SkypeForBusinessUpdates |
                                ForEach-Object {$_.ProductName} |
                                Sort-Object -Unique |
                                Where-Object {$CurrentProduct.Contains($_)}
            $expectedPatches = $global:SkypeForBusinessUpdates | Where-Object {$_.ProductName -eq $ProductName}
            $actualPatches   = Get-CsServerPatchVersion
            $patchFound      = $expectedPatches | Where-Object {$_.ComponentName -eq ($actualPatches.ComponentName.Split(',')[1].TrimStart(' '))}

            $rd.Execute($null)
            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be ($global:InsightDetections.'IDPatchUpdateAvailable' -f $actualPatches.ComponentName, $actualPatches.Version, $patchFound.Version)
            $rd.Insight.Action    | Should -Be ($global:InsightActions.'IDPatchUpdateAvailable' -f $patchFound.Update, $patchFound.Url)
            $rd.Insight.Status    | Should -Be 'WARNING'
        }
    }
}