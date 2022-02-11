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
# Filename: RDCheckLocalDomainFederationDNSRecord.tests.ps1
# Description: <TODO>
# Owner: João Loureiro <joaol@microsoft.com>
# Created On: 3/13/2020 4:02 PM
#
# Last Modified On: 3/13/2020 4:02 PM
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
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDIncorrectLocalFederationDnsSrvRecord.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDNoDefaultSipDomainFound.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDUnableToConnect.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

    . $sut
}

Describe -Tag 'SfBServer','Rule' "RDCheckLocalDomainFederationDNSRecord" {
    Context "RDCheckLocalDomainFederationDNSRecord" {
        BeforeAll {
            Mock Get-ParameterDefinition {return "user1"} -ParameterFilter {$ParameterName -eq "PDEdgeUserID"}
            Mock Get-ParameterDefinition {ConvertTo-SecureString "password" -AsPlainText -Force} -ParameterFilter {$ParameterName -eq "PDEdgePassword"}

            $UserId           = Get-ParameterDefinition -ParameterName 'PDEdgeUserID'
            $Password         = Get-ParameterDefinition -ParameterName 'PDEdgePassword'

            $CredentialObject = New-Object -TypeName System.Management.Automation.PSCredential($UserId, $Password)
        }

        BeforeEach {
            Mock Get-PSSession { "howdy"}

            Mock Get-CsSipDomain {
                @(
                    @{
                        Identity  = "test.com"
                        Name      = "test.com"
                        IsDefault = $false
                    },
                    @{
                        Identity  = "contoso.com"
                        Name      = "contoso.com"
                        IsDefault = $true
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

            Mock Get-CsPool {
                @(
                    @{
                        Computers = @( "edge.contoso.com")
                        Fqdn = "edge.contoso.com"
                    }
                )
            }

            Mock Invoke-RemoteCommand {
                @(
                    @{
                        QueryType    = "SRV"
                        Target       = "sip.contoso.com"
                        NameTarget   = "sip.contoso.com"
                        Priority     = 0
                        Weight       = 0
                        Port         = 5061
                        Name         = "_sipfederationtls._tcp.contoso.com"
                        Type         = "SRV"
                        CharacterSet = "Unicode"
                        Section      = "Answer"
                        DataLength   = 16
                        TTL          = 2854
                    }
                )
            } -ParameterFilter {$ArgumentList -eq '_sipfederationtls._tcp.contoso.com'}

            Mock Invoke-RemoteCommand {
                @(
                    @{
                        Address      = "8.37.44.223"
                        IPAddress    = "8.37.44.223"
                        QueryType    = "A"
                        IP4Address   = "8.37.44.223"
                        Name         = "sip.contoso.com"
                        Type         = "A"
                        CharacterSet = "Unicode"
                        Section      = "Answer"
                        DataLength   = 4
                        TTL          = 2345
                    }
                )
            } -ParameterFilter {$ArgumentList -eq 'sip.contoso.com'}

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

            Mock Test-NetConnection {
                @(
                    @{
                        ComputerName     = "edge.contoso.com"
                        RemoteAddress    = [ipaddress]"192.168.2.62"
                        RemotePort       = 5985
                        InterfaceAlias   = "NIC1"
                        SourceAddress    = [ipaddress]"192.168.2.54"
                        TcpTestSucceeded = $true
                    }
                )
            }

            Mock Write-OPDEventLog {}

            $rule = [RDCheckLocalDomainFederationDNSRecord]::new([IDIncorrectLocalFederationDnsSrvRecord]::new())
        }

        It "No failures" {
            $rule.Execute(@{Obj=$null;Credential=$CredentialObject})

            $rule.Success | Should -BeTrue
        }

        It "No Sip Domains found (IDNoDefaultSipDomainFound)" {
            Mock  Get-CsSipDomain {}

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoDefaultSipDomainFound'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.('IDNoDefaultSipDomainFound')
            $rule.Insight.Action    | Should -Be $global:InsightActions.('IDNoDefaultSipDomainFound')

        }

        It "No edge pools found (Wrong port-IDGetCsServiceFails)" {
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

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDGetCsServiceFails'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.('IDGetCsServiceFails')
            $rule.Insight.Action    | Should -Be $global:InsightActions.('IDGetCsServiceFails')
        }

        It "Unable to reach edge server (IDEdgeServerNotReachable)" {
            Mock Test-NetConnection {
                @(
                    @{
                        ComputerName     = "edge.contoso.com"
                        RemoteAddress    = [ipaddress]"192.168.2.62"
                        RemotePort       = 5985
                        InterfaceAlias   = "NIC1"
                        SourceAddress    = [ipaddress]"192.168.2.54"
                        TcpTestSucceeded = $false
                    }
                )
            }

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDEdgeServerNotReachable'
            $rule.Insight.Detection | Should -Be (($global:InsightDetections.('IDEdgeServerNotReachable')) -f "edge.contoso.com")
        }
    }
}