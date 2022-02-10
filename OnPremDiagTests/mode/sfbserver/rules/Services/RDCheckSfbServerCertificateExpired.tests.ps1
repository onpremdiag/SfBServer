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
# Filename: RDCheckSfbServerCertificateExpired.tests.ps1
# Description: Determine if local system Skype for Business Server certificate
# is expired
#
# Owner: João Loureiro <joaol@microsoft.com>
# Created On: 11/08/2019 3:59 PM
#
# Last Modified On: 11/08/2019 3:59 PM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
    $sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
    $root     = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
    $srcRoot  = "$root\src"
    $testRoot = "$root\OnPremDiagTests"
    $testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
    $mode     = $Matches.Mode

    Get-ChildItem -Path "$srcRoot\classes" -Recurse -Filter *.ps1 | ForEach-Object {. $_.FullName}

    # Load resource files needed for tests
    . "$testRoot\testhelpers\LoadResourceFiles.ps1"
    Import-ResourceFiles -Root $srcRoot -MyMode $mode

    . (Join-Path -Path $srcRoot -ChildPath "common\Globals.ps1")
    . (Join-Path -Path $srcRoot -ChildPath "common\Utils.ps1")
    . (Join-Path -Path $srcRoot -ChildPath "mode\$mode\common\Globals.ps1")
    . (Join-Path -Path $srcRoot -ChildPath "mode\$mode\common\$mode.ps1")
    . (Join-Path -Path $srcRoot -ChildPath "classes\RuleDefinition.ps1")
    . (Join-Path -Path $srcRoot -ChildPath "classes\InsightDefinition.ps1")
    . (Join-Path -Path $srcRoot -ChildPath "mode\$mode\insights\Services\IDSfbServerCertificateIsExpired.ps1")
    . (Join-Path -Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

    . $sut
}

Describe -Tag 'SfBServer' "Check to see if local system Skype for Business Server certificate has expired" {
    BeforeAll {
        Mock Write-OPDEventLog {}
    }

    BeforeEach {
        $rd = [RDCheckSfbServerCertificateExpired]::new([IDSfbServerCertificateIsExpired]::new())
    }

    Context "RDCheckSfbServerCertificateExpired" {
        It "Should find multiple expired certificates" {
            $expiryDate = (Get-Date).AddDays(-1)

            Mock Get-CsCertificate {
                @(
                    @{
                        Subject      = 'CN=sfb2019.contoso.com'
                        SerialNumber = "23000000046EBBA339DD3E66F3000000000004"
                        NotAfter     = $expiryDate
                    },
                    @{
                        Subject      = 'CN=sfb2019.contoso.com'
                        SerialNumber = "23000000046EBBA339DD3E66F3000000000005"
                        NotAfter     = $expiryDate
                    },
                    @{
                        Subject      = 'CN=sfb2019.contoso.com'
                        SerialNumber = "23000000046EBBA339DD3E66F3000000000006"
                        NotAfter     = $expiryDate
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "Should find a single expired certificate" {
            $expiryDate = (Get-Date).AddDays(-1)

            Mock Get-CsCertificate {
                @(
                    @{
                        Subject      = 'CN=sfb2019.contoso.com'
                        SerialNumber = "23000000046EBBA339DD3E66F3000000000004"
                        NotAfter     = $expiryDate
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
        }

        It "Local Skype for Business Server certificate is not expired" {
            Mock Get-CsCertificate {
                @(
                    @{
                        Subject      = 'CN=sfb2019.contoso.com'
                        SerialNumber = "23000000046EBBA339DD3E66F3000000000004"
                        NotAfter     = (Get-Date).AddDays(1)
                        Use          = "Default"
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
        }

        It "Local Skype for Business Server certificate is not expired but has wrong use category" {
            Mock Get-CsCertificate {
                @(
                    @{
                        Subject      = 'CN=sfb2019.contoso.com'
                        SerialNumber = "23000000046EBBA339DD3E66F3000000000004"
                        NotAfter     = (Get-Date).AddDays(1)
                        Use          = "WebServicesInternal"
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
        }
    }
}
