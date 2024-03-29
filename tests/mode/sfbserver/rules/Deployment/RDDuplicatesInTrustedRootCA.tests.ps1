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
# Filename: RDDuplicatesInTrustedRootCA.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 12/9/2020 10:58 AM
#
# Last Modified On: 12/9/2020 10:58 AM
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
    . (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDLocalCertStoreNotFound.ps1")
    . (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDDuplicatesInTrustedRootCA.ps1")
    . (Join-Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

    . $sut
}

Describe -Tag 'SfBServer', 'Rule' "RDDuplicatesInTrustedRootCA" {
	Context "RDDuplicatesInTrustedRootCA" {
		BeforeAll {
			Mock Write-OPDEventLog {}
            $certStore = @()

            $certStore += New-Object PSObject -Property @{
                FriendlyName = "Microsoft Root Certificate Authority"
                Issuer       = "CN=Microsoft Root Certificate Authority, DC=microsoft, DC=com"
                Subject      = "CN=Microsoft Root Certificate Authority, DC=microsoft, DC=com"
                Thumbprint   = "CDD4EEAE6000AC7F40C3802C171E30148030C072"
            }

            $certStore += New-Object PSObject -Property @{
                FriendlyName = "Thawte Timestamping CA"
                Issuer       = "CN=Thawte Timestamping CA, OU=Thawte Certification, O=Thawte, L=Durbanville, S=Western Cape, C=ZA"
                Subject      = "CN=Thawte Timestamping CA, OU=Thawte Certification, O=Thawte, L=Durbanville, S=Western Cape, C=ZA"
                Thumbprint   = "BE36A4562FB2EE05DBB3D32323ADF445084ED656"
            }

            $certStore += New-Object PSObject -Property @{
                FriendlyName = "Thawte Timestamping CA"
                Issuer       = "CN=Thawte Timestamping CA, OU=Thawte Certification, O=Thawte, L=Durbanville, S=Western Cape, C=ZA"
                Subject      = "CN=Thawte Timestamping CA, OU=Thawte Certification, O=Thawte, L=Durbanville, S=Western Cape, C=ZA"
                Thumbprint   = "BE36A4562FB2EE05DBB3D32323ADF445084ED657"
            }
		}

		BeforeEach {
            $rule = [RDDuplicatesInTrustedRootCA]::new([IDLocalCertStoreNotFound]::new())
		}

		It "No Issues (Success)" {
			Mock Test-Path { $true }

			Mock Get-ChildItem { $certStore }

            $rule.Execute($null)
            $rule.Success           | Should -BeTrue
            $rule.Insight.Name      | Should -Be 'IDLocalCertStoreNotFound'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "Local Machine Certificate Store not found (IDLocalCertStoreNotFound)" {
			Mock Test-Path { $false }

			Mock Get-ChildItem { $certStore }

            $rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDLocalCertStoreNotFound'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		#It "Duplicates found in Local Machine Certificate Store (IDDuplicatesInTrustedRootCA)" {
  #          $certStore += New-Object PSObject -Property @{
  #              FriendlyName = "Thawte Timestamping CA"
  #              Issuer       = "CN=Thawte Timestamping CA, OU=Thawte Certification, O=Thawte, L=Durbanville, S=Western Cape, C=ZA"
  #              Subject      = "CN=Thawte Timestamping CA, OU=Thawte Certification, O=Thawte, L=Durbanville, S=Western Cape, C=ZA"
  #              Thumbprint   = "BE36A4562FB2EE05DBB3D32323ADF445084ED657"
  #          }

  #          Mock Test-Path { $true }

		#	Mock Get-ChildItem { $certStore }

  #          $rule.Execute($null)
  #          $rule.Success           | Should -BeFalse
  #          $rule.Insight.Name      | Should -Be 'IDDuplicatesInTrustedRootCA'

  #          $sb        = New-Object Text.StringBuilder
  #          $duplicate = $certStore | Where-Object {$_.Thumbprint -eq 'BE36A4562FB2EE05DBB3D32323ADF445084ED657'} |
  #                          Sort-Object -Unique
  #          $msg = $global:InsightDetections.'IDDuplicatesInTrustedRootCA' -f `
  #                          $duplicate.FriendlyName, $duplicate.Issuer, $duplicate.Subject, $duplicate.Thumbprint
  #          $sb.AppendLine($msg) | Out-Null

  #          $rule.Insight.Detection | Should -Be $sb.ToString()
  #          $rule.Insight.Action    | Should -Be ($global:InsightActions.($rule.Insight.Name) -f $global:LocalMachineCertificateStore)
		#}
	}
}