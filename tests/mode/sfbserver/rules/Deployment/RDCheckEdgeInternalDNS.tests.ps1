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
# Filename: RDCheckEdgeInternalDNS.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/17/2020 9:47 AM
#
# Last Modified On: 9/17/2020 9:47 AM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
    $sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
    $root     = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
    $myPath   = $PSCommandPath
    $srcRoot  = "$root\src"
    $testRoot = "$root\OnPremDiagTests"
    $testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
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
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDNameResolutionFails.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDNoIPAddressForHostName.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDNoDNSRecordFound.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDNoRegistrarServerFound.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDNoEdgePoolsFound.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

    . $sut
}

Describe -Tag 'SfBServer' "RDCheckEdgeInternalDNS" {
    Context "RDCheckEdgeInternalDNS" {
        BeforeAll {
            Mock Get-ParameterDefinition {return "user1"} -ParameterFilter {$ParameterName -eq "PDEdgeUserID"}
            Mock Get-ParameterDefinition {ConvertTo-SecureString "password" -AsPlainText -Force} -ParameterFilter {$ParameterName -eq "PDEdgePassword"}

            $UserId           = Get-ParameterDefinition -ParameterName 'PDEdgeUserID'
            $Password         = Get-ParameterDefinition -ParameterName 'PDEdgePassword'

            $CredentialObject = New-Object -TypeName System.Management.Automation.PSCredential($UserId, $Password)
            Mock Write-OPDEventLog {}
        }

        BeforeEach {
            Mock Get-CsComputer {
                @(
                    @{
                        Identity = "sfb2019.contoso.com"
                        Pool     = "sfb2019.contoso.com"
                        Fqdn     = "sfb2019.contoso.com"
                    }
                )
            }

            Mock Get-CsService {
                @(
                    @{
                        Identity                      = "EdgeServer:edge.contoso.com"
                        Registrar                     = "Registrar:sfb2019.contoso.com"
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

            Mock Invoke-RemoteCommand {
                @(
                    @{
                        Address      = "192.168.0.1"
                        IPAddress    = "192.168.0.1"
                        QueryType    = "A"
                        IP4Address   = "192.168.0.1"
                        Name         = "sipfed.online.lync.com"
                        Type         = "A"
                        CharacterSet = "Unicode"
                        Section      = "Answer"
                        DataLength   = 4
                        TTL          = 1
                    }
                )
            } -ParameterFilter { $scriptBlock -like '*Resolve-DnsName*' }

            Mock Invoke-RemoteCommand { 'sfb2019.contoso.com' } -ParameterFilter {$scriptBlock -like '*GetHostEntry*' }

            Mock New-PSSession {
                @(
                    @{
                        State                  = "Opened"
                        IdleTimeout            = 7200000
                        OutputBufferingMode    = "Block"
                        ComputerType           = "RemoteMachine"
                        ComputerName           = "edge.contoso.com"
                        InstanceId             = "e68296a0-79ef-46d5-954f-5451ca83db1e"
                        Id                     = 4
                        Name                   = "EdgeServer"
                        Availability           = "Available"
                    }
                )
            }

            $rule = [RDCheckEdgeInternalDNS]::new([IDNameResolutionFails]::new())
        }

        It "No issues (Success)" {
            $rule.Execute(@{Obj=$null;Credential=$CredentialObject})

            $rule.Success           | Should -BeTrue
            $rule.Insight.Name      | Should -Be 'IDNameResolutionFails'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDNameResolutionFails'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDNameResolutionFails'
        }

        It "No result returned (IDPropertyNotFoundException)" {
            Mock Get-CsService {$null}

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDPropertyNotFoundException'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDPropertyNotFoundException'
        }

        It "No edge pools found (IDNoEdgePoolsFound)" {
            Mock Get-CsService {
                @(
                    @{
                        Identity                      = "EdgeServer:edge.contoso.com"
                        Registrar                     = "Registrar:sfb2019.contoso.com"
                        AccessEdgeInternalSipPort     = 5061
                        AccessEdgeExternalSipPort     = 9999
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

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoEdgePoolsFound'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDNoEdgePoolsFound'
        }

        It "Unable to acquire remote session (IDUnableToConnect)" {

            Mock New-PSSession {}

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDUnableToConnect'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDUnableToConnect' -f "edge.contoso.com")
            $rule.Insight.Action    | Should -Be ($global:InsightActions.'IDUnableToConnect' -f "edge.contoso.com")
        }

        It "Server name should match registrar server (IDIPv4DoesNotMatchReverseLookup)" {
            Mock Invoke-RemoteCommand { 'sfb2019.tailspin.com' } -ParameterFilter {$scriptBlock -like '*GetHostEntry*' }
            Mock Get-CsService {
                @(
                    @{
                        Identity                      = "EdgeServer:edge.contoso.com"
                        Registrar                     = "Registrar:letmeout.contoso.com"
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

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDIPv4DoesNotMatchReverseLookup'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDIPv4DoesNotMatchReverseLookup' -f '192.168.0.1','letmeout.contoso.com','sfb2019.tailspin.com')
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDIPv4DoesNotMatchReverseLookup'
        }

        It "Record found but no IP address associated with it (IDNoIPAddressForHostName)" {
            Mock Invoke-RemoteCommand {
                @(
                    @{
                        Address      = "192.168.0.1"
                        IPAddress    = [string]::Empty
                        QueryType    = "A"
                        IP4Address   = "192.168.0.1"
                        Name         = "sipfed.online.lync.com"
                        Type         = "A"
                        CharacterSet = "Unicode"
                        Section      = "Answer"
                        DataLength   = 4
                        TTL          = 1
                    }
                )
            } -ParameterFilter { $scriptBlock -like '*Resolve-DnsName*' }

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoIPAddressForHostName'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDNoIPAddressForHostName' -f 'sfb2019.contoso.com')
            $rule.Insight.Action    | Should -Be ($global:InsightActions.'IDNoIPAddressForHostName' -f 'sfb2019.contoso.com')
        }

        It "No DNS record found for host (IDNoDNSRecordFound)" {
            Mock Invoke-RemoteCommand {} -ParameterFilter { $scriptBlock -like '*Resolve-DnsName*' }

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoDNSRecordFound'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDNoDNSRecordFound'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDNoDNSRecordFound'
        }

        It "No registrar server found (IDNoRegistrarServerFound)" {
            Mock Get-CsService {
                @(
                    @{
                        Identity                      = "EdgeServer:edge.contoso.com"
                        Registrar                     = "Registrar:"
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

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoRegistrarServerFound'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDNoRegistrarServerFound' -f 'edge.contoso.com')
            $rule.Insight.Action    | Should -Be ($global:InsightActions.'IDNoRegistrarServerFound' -f 'edge.contoso.com')
        }

        It "No edge server found (IDNoRegistrarServerFound)" {
            Mock Get-CsService {
                @(
                    @{
                        Identity                      = "EdgeServer:"
                        Registrar                     = "Registrar:sfb2019.contoso.com"
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

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoRegistrarServerFound'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDNoRegistrarServerFound' -f 'edge.contoso.com')
            $rule.Insight.Action    | Should -Be ($global:InsightActions.'IDNoRegistrarServerFound' -f 'edge.contoso.com')
        }
    }
}