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
# Filename: RDCheckEdgePoolCount.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/14/2020 1:37 PM
#
# Last Modified On: 1/14/2020 1:37 PM
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
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDIncorrectFederationRoute.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

    . $sut
}

Describe -Tag 'SfBServer','Rules' "RDCheckEdgePoolCount" {
    Context "Check edge pool server count" {
        BeforeEach {
            Mock Write-OPDEventLog {}

            $rd = [RDCheckEdgePoolCount]::new([IDIncorrectFederationRoute]::new())
        }

        It "Constructor worked" {
            $rd.Name        | Should -Be 'RDCheckEdgePoolCount'
            $rd.Description | Should -Not -BeNullOrEmpty
            $rd.ExecutionId | Should -Be ([guid]::Empty)
            $rd.Success     | Should -BeTrue
            $rd.Insight     | Should -Not -BeNullOrEmpty
            $rd.EventId     | Should -Not -BeNullOrEmpty
        }

        It "Edge pool server count == 0" {
            Mock Get-CsService { @() }

            $rd.Execute($null)

            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "Edge pool server count == 1" {
            Mock Get-CsService {
                @(
                    @{
                        Identity                      = "EdgeServer:edge.contoso.com"
                        Registrar                     = "Registrar:sfb2019.contoso.com"
                        AccessEdgeInternalSipPort     = 5061
                        AccessEdgeExternalSipPort     = 5061
                        AccessEdgeClientSipPort       = 5061
                        DataPsomServerPort            = 8057
                        DataPsomClientPort            = 444
                        MediaRelayAuthEdgePort        = 5062
                        MediaRelayInternalTurnTcpPort = 443
                        MediaRelayExternalTurnTcpPort = 443
                        MediaRelayInternalTurnUdpPort = 3478
                        MediaRelayExternalTurnUdpPort = 3478
                        MediaCommunicationPortStart   = 50000
                        MediaCommunicationPortCount   = 10000
                        AccessEdgeExternalFqdn        = "sip.contoso.com"
                        DataEdgeExternalFqdn          = "sip.contoso.com"
                        AVEdgeExternalFqdn            = "sip.contoso.com"
                        InternalInterfaceFqdn         = [string]::Empty
                        ExternalMrasFqdn              = "sip.contoso.com"
                        XmppInternalPort              = [string]::Empty
                        XmppListeningPort             = [string]::Empty
                        SkypeSearchProxyPort          = 4443
                        DependentServiceList          = @{
                            Registrar          = "sfb2019.contoso.com"
                            ConferencingServer = "sfb2019.contoso.com"
                            MediationServer    = "sfb2019.contoso.com"
                        }
                        ServiceId                     = "1-EdgeServer-1"
                        SiteId                        = "Site:contoso"
                        PoolFqdn                      = "edge.contoso.com"
                        Version                       = 8
                        Role                          = "EdgeServer"
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "Edge pool server count > 1" {
            Mock Get-CsService {
                @(
                    @{
                        Identity                      = "EdgeServer:edge.contoso.com"
                        Registrar                     = "Registrar:sfb2019.contoso.com"
                        AccessEdgeInternalSipPort     = 5061
                        AccessEdgeExternalSipPort     = 5061
                        AccessEdgeClientSipPort       = 5061
                        DataPsomServerPort            = 8057
                        DataPsomClientPort            = 444
                        MediaRelayAuthEdgePort        = 5062
                        MediaRelayInternalTurnTcpPort = 443
                        MediaRelayExternalTurnTcpPort = 443
                        MediaRelayInternalTurnUdpPort = 3478
                        MediaRelayExternalTurnUdpPort = 3478
                        MediaCommunicationPortStart   = 50000
                        MediaCommunicationPortCount   = 10000
                        AccessEdgeExternalFqdn        = "sip.contoso.com"
                        DataEdgeExternalFqdn          = "sip.contoso.com"
                        AVEdgeExternalFqdn            = "sip.contoso.com"
                        InternalInterfaceFqdn         = [string]::Empty
                        ExternalMrasFqdn              = "sip.contoso.com"
                        XmppInternalPort              = [string]::Empty
                        XmppListeningPort             = [string]::Empty
                        SkypeSearchProxyPort          = 4443
                        DependentServiceList          = @{
                            Registrar          = "sfb2019.contoso.com"
                            ConferencingServer = "sfb2019.contoso.com"
                            MediationServer    = "sfb2019.contoso.com"
                        }
                        ServiceId                     = "1-EdgeServer-1"
                        SiteId                        = "Site:contoso"
                        PoolFqdn                      = "edge.contoso.com"
                        Version                       = 8
                        Role                          = "EdgeServer"
                    },
                    @{
                        Identity                      = "EdgeServer:edge.contoso.com"
                        Registrar                     = "Registrar:sfb2019.contoso.com"
                        AccessEdgeInternalSipPort     = 5061
                        AccessEdgeExternalSipPort     = 5061
                        AccessEdgeClientSipPort       = 5061
                        DataPsomServerPort            = 8057
                        DataPsomClientPort            = 444
                        MediaRelayAuthEdgePort        = 5062
                        MediaRelayInternalTurnTcpPort = 443
                        MediaRelayExternalTurnTcpPort = 443
                        MediaRelayInternalTurnUdpPort = 3478
                        MediaRelayExternalTurnUdpPort = 3478
                        MediaCommunicationPortStart   = 50000
                        MediaCommunicationPortCount   = 10000
                        AccessEdgeExternalFqdn        = "sip.contoso.com"
                        DataEdgeExternalFqdn          = "sip.contoso.com"
                        AVEdgeExternalFqdn            = "sip.contoso.com"
                        InternalInterfaceFqdn         = [string]::Empty
                        ExternalMrasFqdn              = "sip.contoso.com"
                        XmppInternalPort              = [string]::Empty
                        XmppListeningPort             = [string]::Empty
                        SkypeSearchProxyPort          = 4443
                        DependentServiceList          = @{
                            Registrar          = "sfb2019.contoso.com"
                            ConferencingServer = "sfb2019.contoso.com"
                            MediationServer    = "sfb2019.contoso.com"
                        }
                        ServiceId                     = "1-EdgeServer-1"
                        SiteId                        = "Site:contoso"
                        PoolFqdn                      = "edge1.contoso.com"
                        Version                       = 8
                        Role                          = "EdgeServer"
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

    }
}