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
# Filename: RDCheckSharedAddressSpace.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/16/2020 10:11 AM
#
# Last Modified On: 1/16/2020 10:11 AM
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
    . "$testRoot\testhelpers\LoadResourceFiles.ps1"
    Import-ResourceFiles -Root $srcRoot -MyMode $mode

    . "$srcRoot\common\Globals.ps1"
    . "$srcRoot\common\Utils.ps1"
    . "$srcRoot\mode\$mode\common\Globals.ps1"
    . "$srcRoot\mode\$mode\common\$mode.ps1"
    . "$srcRoot\classes\RuleDefinition.ps1"
    . "$srcRoot\classes\InsightDefinition.ps1"
    . "$srcRoot\mode\$mode\insights\Deployment\IDSIPHostingProviderSharedAddressSpaceNotEnabled.ps1"
    . "$testRoot\mocks\SfbServerMock.ps1"

    . $sut
}

Describe -Tag 'SfBServer' "RDCheckSharedAddressSpace" {
    Context "Checks the value for SharedAddressSpace for the SIP Hosting Provider" {
        BeforeEach {
            Mock Write-OPDEventLog {}
            $rd = [RDCheckSharedAddressSpace]::new([IDSIPHostingProviderSharedAddressSpaceNotEnabled]::new())
        }

        It "EnabledSharedAddressSpace is true" {
            Mock Get-CsHostingProvider {
                @(
                    @{
                        Identity                  = "Skype For Business Online"
                        Name                      = "Skype For Business Online"
                        ProxyFqdn                 = $global:SIPProxyFQDN
                        VerificationLevel         = "UseSourceVerification"
                        Enabled                   = $true
                        EnabledSharedAddressSpace = $true
                        HostsOCSUsers             = $true
                        IsLocal                   = $false
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "EnabledSharedAddressSpace is false" {
            Mock Get-CsHostingProvider {
                @(
                    @{
                        Identity                  = "Skype For Business Online"
                        Name                      = "Skype For Business Online"
                        ProxyFqdn                 = $global:SIPProxyFQDN
                        VerificationLevel         = "UseSourceVerification"
                        Enabled                   = $true
                        EnabledSharedAddressSpace = $false
                        HostsOCSUsers             = $true
                        IsLocal                   = $false
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "EnabledSharedAddressSpace is empty" {
            Mock Get-CsHostingProvider {
                @(
                    @{
                        Identity                  = "Skype For Business Online"
                        Name                      = "Skype For Business Online"
                        ProxyFqdn                 = $global:SIPProxyFQDN
                        VerificationLevel         = "UseSourceVerification"
                        Enabled                   = $true
                        EnabledSharedAddressSpace = [string]::Empty
                        HostsOCSUsers             = $true
                        IsLocal                   = $false
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "EnabledSharedAddressSpace is null" {
            Mock Get-CsHostingProvider {
                @(
                    @{
                        Identity                  = "Skype For Business Online"
                        Name                      = "Skype For Business Online"
                        ProxyFqdn                 = $global:SIPProxyFQDN
                        VerificationLevel         = "UseSourceVerification"
                        Enabled                   = $true
                        EnabledSharedAddressSpace = $null
                        HostsOCSUsers             = $true
                        IsLocal                   = $false
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "Get-CsHostingProider returns no result" {
            Mock Get-CsHostingProvider { $null }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }
    }
}