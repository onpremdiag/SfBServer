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
# Filename: RDCheckDNSResolution.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 7/20/2020 12:15 PM
#
# Last Modified On: 7/20/2020 12:15 PM
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
. "$testRoot\testhelpers\LoadResourceFiles.ps1"
Import-ResourceFiles -Root $srcRoot -MyMode $mode

. (Join-Path -Path $srcRoot  -ChildPath "common\Globals.ps1")
. (Join-Path -Path $srcRoot  -ChildPath "common\Utils.ps1")
. (Join-Path -Path $srcRoot  -ChildPath "mode\$mode\common\Globals.ps1")
. (Join-Path -Path $srcRoot  -ChildPath "mode\$mode\common\$mode.ps1")
. (Join-Path -Path $srcRoot  -ChildPath "classes\RuleDefinition.ps1")
. (Join-Path -Path $srcRoot  -ChildPath "classes\InsightDefinition.ps1")
. (Join-Path -Path $srcRoot  -ChildPath "mode\$mode\insights\Services\IDIPv4DoesNotMatchReverseLookup.ps1")
. (Join-Path -Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

. $sut

Describe -Tag 'SfBServer' "RDCheckDNSResolution" {
    BeforeAll {
        Mock Write-OPDEventLog {}

        Mock Resolve-DnsName {
            @(
                @{
                    Address      = "127.0.0.1"
                    IPAddress    = "127.0.0.1"
                    QueryType    = "A"
                    IP4Address   = "127.0.0.1"
                    Name         = "sfb2019.contoso.com"
                    Type         = "A"
                    CharacterSet = "Unicode"
                    Section      = "Answer"
                    DataLength   = 4
                    TTL          = 1200
                }
            )
        }

        Mock Get-HostEntry { return "sfb2019.contoso.com" }
    }

    BeforeEach {
        $rd = [RDCheckDNSResolution]::new([IDIPv4DoesNotMatchReverseLookup]::new())
    }

    Context "Check to see if DNS IPv4 IP can be resolved and that the reverse" {
        It "Resolution is good" {
            Mock Get-CsComputer {
                @(
                    @{
                        Identity = "sfb2019.contoso.com"
                        Pool     = "sfb2019.contoso.com"
                        Fqdn     = "sfb2019.contoso.com"
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
        }

        It "Does not match" {
            Mock Get-HostEntry { return "sfb2018.contoso.com"}
            $DNSAddress = Resolve-DnsName -Name "anything"

            $rd.Execute($null)
            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
            $rd.Insight.Detection | Should -Be ($global:InsightDetections.($rd.Insight.Name) -f $DNSAddress.IP4Address,"sfb2019.contoso.com", "sfb2018.contoso.com")
        }

        It "Unable to Resolve-DnsName (IDUnableToResolveDNSName)" {
            Mock Resolve-DnsName {}

            $rd.Execute($null)
            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Name      | Should -Be 'IDUnableToResolveDNSName'
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
        }

        It "Unable to resolve Pool name (IDNullOrEmptyPoolFQDN)" {
            Mock Get-CsComputer {
                @(
                    @{
                        Identity = "sfb2019.contoso.com"
                        Pool     = [string]::Empty
                        Fqdn     = "sfb2019.contoso.com"
                    }
                )
            }

            Mock Resolve-DnsName {
                @(
                    @{
                        Address      = "127.0.0.1"
                        IPAddress    = "127.0.0.1"
                        QueryType    = "A"
                        IP4Address   = "127.0.0.1"
                        Name         = "sfb2019.contoso.com"
                        Type         = "A"
                        CharacterSet = "Unicode"
                        Section      = "Answer"
                        DataLength   = 4
                        TTL          = 1200
                    }
                )
            }

            $PoolFQDN = Get-CsComputer

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Name      | Should -Be 'IDNullOrEmptyPoolFQDN'
            $rd.Insight.Action    | Should -Be ($global:InsightActions.($rd.Insight.Name) -f $PoolFQDN.Fqdn)
            $rd.Insight.Detection | Should -Be ($global:InsightDetections.($rd.Insight.Name) -f $PoolFQDN.Fqdn)
        }

        It "Unable to resolve Server FQDN (IDUnableToResolveServerFQDN)" {
            Mock Resolve-DnsName {
                @(
                    @{
                        Address      = "127.0.0.1"
                        IPAddress    = "127.0.0.1"
                        QueryType    = "A"
                        IP4Address   = "127.0.0.1"
                        Name         = [string]::Empty
                        Type         = "A"
                        CharacterSet = "Unicode"
                        Section      = "Answer"
                        DataLength   = 4
                        TTL          = 1200
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Name      | Should -Be 'IDUnableToResolveServerFQDN'
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
        }
    }
}