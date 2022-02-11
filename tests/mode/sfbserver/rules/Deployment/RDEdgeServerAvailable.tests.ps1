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
# Filename: RDEdgeServerAvailable.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/5/2020 9:53 AM
#
# Last Modified On: 2/5/2020 9:53 AM
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
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDEdgeServerNotReachable.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDGetCsServiceFails.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDEdgeServerNotListening.ps1")
. (Join-Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

. $sut

Describe -Tag 'SfBServer','Rules' "RDEdgeServerAvailable" {
    Context "Check if the Edge Server is reachable" {
        BeforeEach {
            Mock Write-OPDEventLog {}

            Mock Get-CsService {
                @(
                    @{
                        Identity                     = "UserServer:sfb2019.contoso.com"
                        UserDatabase                 = "UserDatabase:sfb2019.contoso.com"
                        McuFactorySipPort            = [uint16]444
                        UserPinManagementWcfHttpPort = [uint16]443
                        SiteId                       = "Site:contoso"
                        PoolFqdn                     = "sfb2019.contoso.com"
                        Role                         = "UserServer"
                        AccessEdgeExternalSipPort    = 5061
                    }
                )
            }

            Mock Get-CsPool {
                @(
                    @{
                        Identity = "sfb2019.contoso.com"
                        Computers = @(
                            'sfb2019.contoso.com'
                        )
                    }
                )
            }

            Mock Test-ConnectionLocalSubnet { $true }

            $rule = [RDEdgeServerAvailable]::new([IDEdgeServerNotReachable]::new([OPDStatus]::WARNING))
        }

        It "No issues (SUCCESS)" {
            $rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.Insight.Name      | Should -Be 'IDEdgeServerNotReachable'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
        }

        It "No values returned from Get-CsService (IDGetCsServiceFails)" {
            Mock Get-CsService {}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDGetCsServiceFails'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
            $rule.Insight.Status    | Should -Be 'WARNING'
        }

        It "Unable to verify connection with Edge server (IDEdgeServerNotListening)" {
            Mock Test-ConnectionLocalSubnet {$false}

            $EdgeServer = (Get-CsService).PoolFqdn

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDEdgeServerNotListening'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f $EdgeServer)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
            $rule.Insight.Status    | Should -Be 'WARNING'
        }
    }
}