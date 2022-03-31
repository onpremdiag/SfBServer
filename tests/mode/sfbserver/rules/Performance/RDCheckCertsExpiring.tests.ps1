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
# Filename: RDCheckCertsExpiring.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/3/2022 10:22:33 AM
#
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
    . (Join-Path -Path $testRoot -ChildPath testhelpers\LoadResourceFiles.ps1)

    Import-ResourceFiles -Root $srcRoot -MyMode $mode

    . (Join-Path -Path $srcRoot -ChildPath common\Globals.ps1)
    . (Join-Path -Path $srcRoot -ChildPath common\Utils.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\Globals.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\$mode.ps1)
    . (Join-Path -Path $srcRoot -ChildPath classes\RuleDefinition.ps1)
    . (Join-Path -Path $srcRoot -ChildPath classes\InsightDefinition.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\performance\IDExpiringCertificates.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\MicrosoftTeamsMocks.ps1)

    . $sut
}

Describe -Tag 'SfBServer' "RDCheckCertsExpiring" {
    Context "Check all the certificates on the local server for expiry <= 45 days" {
        BeforeEach {
            Mock Write-OPDEventLog {}

            $rule = [RDCheckCertsExpiring]::new([IDExpiringCertificates]::new())
        }

        It "No certificates expiring in <= 45 days" {
            Mock Get-CsCertificate {
                @(
                    @{
                        Subject    = 'CN=sfb2019.contoso.com'
                        Thumbprint = "125932D8B79DD3C7784D87B94FCB8CF362B6D9CF"
                        Use        = "AccessEdgeExternal"
                        NotAfter   = (Get-Date).AddYears(1)
                    }
                )
            }

            $rule.Execute($null)
            $rule.Success           | Should -BeTrue
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDExpiringCertificates'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDExpiringCertificates'

        }

        It "A certificate is expiring in <= 45 days" {
            Mock Get-CsCertificate {
                @(
                    @{
                        Subject    = 'CN=sfb2019.contoso.com'
                        Thumbprint = "125932D8B79DD3C7784D87B94FCB8CF362B6D9CF"
                        Use        = "AccessEdgeExternal"
                        NotAfter   = (Get-Date).AddDays(30)
                    },
                    @{
                        Subject    = 'CN=server02.contoso.com'
                        Thumbprint = "125932D8B79DD3C7784D87B94FCB8CF362B6D9FC"
                        Use        = "AccessEdgeExternal"
                        NotAfter   = (Get-Date).AddDays(20)
                    }
                )
            }
            $ExpiringCertificates = Get-CsCertificate

            $rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -BeLike "*$($ExpiringCertificates[0].Subject)*"
            $rule.Insight.Detection | Should -BeLike "*$($ExpiringCertificates[1].Subject)*"
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDExpiringCertificates'

        }
    }
}