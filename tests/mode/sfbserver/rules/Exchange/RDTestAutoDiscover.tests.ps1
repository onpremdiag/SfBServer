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
# Filename: RDTestAutoDiscover.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/23/2020 3:45 PM
#
# Last Modified On: 9/23/2020 3:45 PM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
    $sut      = $PSCommandPath -replace '^(.*)\\tests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
    $root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
    $myPath   = $PSCommandPath
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
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDDNSNameDoesNotExist.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDAutoDiscoverNameDoNotMatch.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDUnknownDomain.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

    . $sut
}

Describe -Tag 'SfBServer' "RDTestAutoDiscover" {
    Context "RDTestAutoDiscover" {
        BeforeAll {
            Mock Write-OPDEventLog {}
            $expectedAutoDiscoverName = "autodiscover.CONTOSO.COM"
        }

        BeforeEach {
            $originalUserDNSDomain    = $env:USERDNSDOMAIN
            $env:USERDNSDOMAIN        = "contoso.com"
            $expectedAutoDiscoverName = "autodiscover.$env:USERDNSDOMAIN"

            Mock Resolve-DnsName {
                @(
                    @{
                        QueryType    = "CNAME"
                        Server       = "CONTOSO.COM"
                        NameHost     = "CONTOSO.COM"
                        Name         = "autodiscover.CONTOSO.COM"
                        Type         = "CNAME"
                        CharacterSet = "Unicode"
                        Section      = "Answer"
                        DataLength   = 32
                        TTL          = 3599
                    }
                )
            } -ParameterFilter { $Type -eq 'CNAME' }

            Mock Resolve-DnsName {
                @(
                    @{
                        Address      = "192.168.2.62"
                        IPAddress    = "192.168.2.62"
                        QueryType    = "A"
                        IP4Address   = "192.168.2.62"
                        Name         = "edge"
                        Type         = "A"
                        CharacterSet = "Unicode"
                        Section      = "Question"
                        DataLength   = 4
                        TTL = 1200
                    }
                )
            } -ParameterFilter { $Type -eq 'A' }

            $rule = [RDTestAutoDiscover]::new([IDUnknownDomain]::new())
        }

        AfterEach {
            $env:USERDNSDOMAIN = $originalUserDNSDomain
        }

        It "No issues (Success)" {
            $rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.Insight.Name      | Should -Be 'IDUnknownDomain'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
        }

        It "Autodiscover not found - DNS record found (Success)" {
            Mock Resolve-DnsName {
                @(
                    @{
                        QueryType    = "CNAME"
                        Server       = "CONTOSO.COM"
                        NameHost     = "CONTOSO.COM"
                        Name         = [string]::Empty
                        Type         = "CNAME"
                        CharacterSet = "Unicode"
                        Section      = "Answer"
                        DataLength   = 32
                        TTL          = 3599
                    }
                )
            } -ParameterFilter { $Type -eq 'CNAME' }

            $rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.Insight.Name      | Should -Be 'IDUnknownDomain'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
        }

        It "Autodiscover found - DNS record not found (Success)" {
            Mock Resolve-DnsName { } -ParameterFilter { $Type -eq 'A' }

            $rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.Insight.Name      | Should -Be 'IDUnknownDomain'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
        }

        It "Unexpected value for autodiscover (IDAutoDiscoverNameDoNotMatch)" {
            $actualAutoDiscoverName = "autodiscover.SPINTOY.COM"

            Mock Resolve-DnsName {
                @(
                    @{
                        QueryType    = "CNAME"
                        Server       = "SPINTOY.COM"
                        NameHost     = "SPINTOY.COM"
                        Name         = $actualAutoDiscoverName
                        Type         = "CNAME"
                        CharacterSet = "Unicode"
                        Section      = "Answer"
                        DataLength   = 32
                        TTL          = 3599
                    }
                )
            } -ParameterFilter { $Type -eq 'CNAME' }

            $actualCNAMERecord = Resolve-DnsName -Type 'CNAME' -Name $actualAutoDiscoverName

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDAutoDiscoverNameDoNotMatch'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f $expectedAutoDiscoverName, $actualCNAMERecord.NameHost)
            $rule.Insight.Action    | Should -Be ($global:InsightActions.($rule.Insight.Name) -f $expectedAutoDiscoverName)

        }

        It "Unable to determine domain name from the environment variable (IDUnknownDomain)" {
            $env:USERDNSDOMAIN    = [string]::Empty

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDUnknownDomain'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)

        }

        It "No A record found either (IDDNSNameDoesNotExist)" {
            Mock Resolve-DnsName { } -ParameterFilter { $Type -eq 'CNAME' }
            Mock Resolve-DnsName { } -ParameterFilter { $Type -eq 'A'}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDDNSNameDoesNotExist'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f $expectedAutoDiscoverName)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
        }
    }
}