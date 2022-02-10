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

$sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
$srcRoot  = "$root\src"
$testRoot = "$root\tests"
$testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
$mode     = $Matches.Mode

Get-ChildItem -Path "$srcRoot\classes" -Recurse -Filter *.ps1 | ForEach-Object {. $_.FullName}

# Load resource files needed for tests
. "$testRoot\testhelpers\LoadResourceFiles.ps1"
Import-ResourceFiles -Root $srcRoot -MyMode $mode

. "$srcRoot\common\Globals.ps1"
. "$srcRoot\common\Utils.ps1"
. "$srcRoot\mode\$mode\common\Globals.ps1"
. "$srcRoot\mode\$mode\common\$mode.ps1"
. "$srcRoot\classes\RuleDefinition.ps1"
. "$srcRoot\classes\InsightDefinition.ps1"
. "$srcRoot\mode\$mode\insights\Services\IDRootCACertificatesMisplaced.ps1"
. "$testRoot\mocks\SfbServerMock.ps1"

. $sut

Describe  -Tag 'SfBServer' "RDCheckMisplacedRootCACertificates" {
    BeforeAll {
        Mock Write-OPDEventLog {}
    }

    BeforeEach {
        $rd = [RDCheckMisplacedRootCACertificates]::new([IDRootCACertificatesMisplaced]::new())
    }

    Context "RDCheckMisplacedRootCACertificates" {
        It "There are no misplaced Root CA Certificates" {
            Mock Get-ChildItem {
                @(
                    @{
                        Issuer  = "CN=Microsoft Root Certificate Authority, DC=microsoft, DC=com"
                        Subject = "CN=Microsoft Root Certificate Authority, DC=microsoft, DC=com"
                    },
                    @{
                        Issuer  = "CN=Thawte Timestamping CA, OU=Thawte Certification, O=Thawte, L=Durbanville, S=Western Cape, C=ZA"
                        Subject = "CN=Thawte Timestamping CA, OU=Thawte Certification, O=Thawte, L=Durbanville, S=Western Cape, C=ZA"
                    },
                    @{
                        Issuer  = "CN=ucstaff-DC-CA, DC=ucstaff, DC=com"
                        Subject = "CN=ucstaff-DC-CA, DC=ucstaff, DC=com"
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)

        }

        It "There is a misplaced Root CA Certificate" {
            Mock Get-ChildItem {
                @(
                    @{
                        Issuer  = "CN=Microsoft Root Certificate Authority, DC=microsoft, DC=com"
                        Subject = "CN=Microsoft Root Certificate Authority, DC=microsoft, DC=com"
                    },
                    @{
                        Issuer  = "CN=Thawte Timestamping CA, OU=Thawte Certification, O=Thawte, L=Durbanville, S=Western Cape, C=ZA"
                        Subject = "CN=Thawte Timestamping CA, OU=Thawte Certification, O=Thawte, L=Durbanville, S=Western Cape, C=ZA"
                    },
                    @{
                        Issuer  = "CN=ucstaff-DC-CA, DC=ucstaff, DC=com"
                        Subject = "CN=ucstaff-DC-CA, DC=ucstaff, DC=edu"
                    }
                )
            }

            $rd.Execute($null)

            $nonRootCertificates = Get-ChildItem $global:LocalMachineCertificateStore -Recurse | Where-Object { $_.Issuer -ne $_.Subject}

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
            $rd.Insight.Detection | Should -Be ($global:InsightDetections.($rd.Insight.Name) -f @($nonRootCertificates).Count)
        }

        It "Certificate store not found/available" {
            Mock Test-Path { $false }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDLocalCertStoreNotFound'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDLocalCertStoreNotFound'
        }
    }
}