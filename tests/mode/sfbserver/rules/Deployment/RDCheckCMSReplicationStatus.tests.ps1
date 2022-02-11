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
# Filename: RDCheckCMSReplicationStatus.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/14/2020 11:22 AM
#
# Last Modified On: 1/14/2020 11:23 AM
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
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDCMSReplicationNotSuccessful.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

    . $sut
}

Describe -Tag 'SfBServer', 'Rule' "RDCheckCMSReplicationStatus" {
    Context "RDCheckCMSReplicationStatus" {
        BeforeEach {
            $timestamp = Get-Date

            Mock Get-CsComputer {
                @(
                    @{
                        Identity = "edge.contoso.com"
                        Pool     = "edge.contoso.com"
                        Fqdn     = "edge.contoso.com"
                    }
                )
            }

            Mock Get-CsManagementStoreReplicationStatus {
                @(
                    @{
                        UpToDate           = $true
                        ReplicaFqdn        = "edge.contoso.com"
                        LastStatusReport   = $timestamp
                        LastUpdateCreation = $timestamp
                        ProductVersion     = "7.0.2046.0"
                    },
                    @{
                        UpToDate           = $true
                        ReplicaFqdn        = "sfb2019.contoso.com"
                        LastStatusReport   = $timestamp
                        LastUpdateCreation = $timestamp
                        ProductVersion     = "7.0.2046.0"
                    }
                )
            }

            Mock Get-CsService {
                @(
                    @{
                        Identity                      = "EdgeServer:edge.ucstaff.com"
                        Registrar                     = "Registrar:sfb2019.ucstaff.com"
                        AccessEdgeInternalSipPort     = 5061
                        AccessEdgeExternalSipPort     = 5061
                        AccessEdgeClientSipPort       = 5061

                        AccessEdgeExternalFqdn        = "sip.contoso.com"
                        DataEdgeExternalFqdn          = "sip.contoso.com"
                        AVEdgeExternalFqdn            = "sip.contoso.com"

                        ExternalMrasFqdn              = "sip.contoso.com"

                        SkypeSearchProxyPort          = 4443
                        DependentServiceList          = @{
                            Registrar          = "sfb2019.contoso.com"
                            ConferencingServer = "sfb2019.contoso.com"
                            MediationServer    = "sfb2019.contoso.com"
                        }
                        ServiceId                     = "1-EdgeServer-1"
                        SiteId                        = "Site:Contoso"
                        PoolFqdn                      = "edge.contoso.com"
                        Version                       = 8
                        Role                          = "EdgeServer"
                    }
                )
            }

            Mock Write-OPDEventLog {}

            $rule = [RDCheckCMSReplicationStatus]::new([IDCMSReplicationNotSuccessful]::new())
        }

        It "No problems found" {

            $rule.Execute($null)

            $rule.Success | Should -BeTrue
        }

        It "Edge server replication is not up to date (IDCMSReplicationNotSuccessful)" {
            Mock Get-CsManagementStoreReplicationStatus {
                @(
                    @{
                        UpToDate           = $false
                        ReplicaFqdn        = "edge.contoso.com"
                        LastStatusReport   = $timestamp
                        LastUpdateCreation = $timestamp
                        ProductVersion     = "7.0.2046.0"
                    },
                    @{
                        UpToDate           = $true
                        ReplicaFqdn        = "sfb2019.contoso.com"
                        LastStatusReport   = $timestamp
                        LastUpdateCreation = $timestamp
                        ProductVersion     = "7.0.2046.0"
                    }
                )
            }

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDCMSReplicationNotSuccessful'
            $rule.Insight.Detection | Should -Be (($global:InsightDetections.'IDCMSReplicationNotSuccessful') -f 'edge.contoso.com')
            $rule.Insight.Action    | Should -Be (($global:InsightActions.'IDCMSReplicationNotSuccessful') -f $timestamp)
        }

        It "Unable to get replication information (IDNoReplicationStatus)" {
            Mock Get-CsManagementStoreReplicationStatus {}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoReplicationStatus'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDNoReplicationStatus')
            $rule.Insight.Action    | Should -Be ($global:InsightActions.'IDNoReplicationStatus')
        }

        It "Edge server with wrong SIP external port (IDEdgeServerWrongExternalSipPort)" {
            Mock Get-CsService {
                @(
                    @{
                        Identity                      = "EdgeServer:edge.ucstaff.com"
                        Registrar                     = "Registrar:sfb2019.ucstaff.com"
                        AccessEdgeInternalSipPort     = 5061
                        AccessEdgeExternalSipPort     = 8888
                        AccessEdgeClientSipPort       = 5061

                        AccessEdgeExternalFqdn        = "sip.contoso.com"
                        DataEdgeExternalFqdn          = "sip.contoso.com"
                        AVEdgeExternalFqdn            = "sip.contoso.com"

                        ExternalMrasFqdn              = "sip.contoso.com"

                        SkypeSearchProxyPort          = 4443
                        DependentServiceList          = @{
                            Registrar          = "sfb2019.contoso.com"
                            ConferencingServer = "sfb2019.contoso.com"
                            MediationServer    = "sfb2019.contoso.com"
                        }
                        ServiceId                     = "1-EdgeServer-1"
                        SiteId                        = "Site:Contoso"
                        PoolFqdn                      = "edge.contoso.com"
                        Version                       = 8
                        Role                          = "EdgeServer"
                    }
                )
            }

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDEdgeServerWrongExternalSipPort'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDEdgeServerWrongExternalSipPort')
            $rule.Insight.Action    | Should -Be ($global:InsightActions.'IDEdgeServerWrongExternalSipPort')
        }

        It "No edge servers found (IDNoEdgeServersFound)" {
            Mock Get-CsComputer {
                @(
                    @{
                        Identity = "edge.contoso.com"
                        Pool     = "edge.contosox.com"
                        Fqdn     = "edge.contoso.com"
                    }
                )
            }

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoEdgeServersFound'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDNoEdgeServersFound')
            $rule.Insight.Action    | Should -Be ($global:InsightActions.'IDNoEdgeServersFound')
        }
    }
}