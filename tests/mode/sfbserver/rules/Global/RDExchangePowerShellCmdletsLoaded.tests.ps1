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
# Filename: RDExchangePowerShellCmdletsLoaded.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/20/2020 12:09 PM
#
# Last Modified On: 10/20/2020 12:09 PM
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
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDNoSession.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDUnableToImportRemoteSession.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDUnableToImportExchangeCmdlets.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\ExchangeMocks.ps1)

    . $sut
}

Describe "RDExchangePowerShellCmdletsLoaded" {
	BeforeAll {
        Mock Get-ParameterDefinition {return "user1"} -ParameterFilter {$ParameterName -eq "PDEdgeUserID"}
        Mock Get-ParameterDefinition {ConvertTo-SecureString "password" -AsPlainText -Force} -ParameterFilter {$ParameterName -eq "PDEdgePassword"}

        $UserId           = Get-ParameterDefinition -ParameterName 'PDEdgeUserID'
        $Password         = Get-ParameterDefinition -ParameterName 'PDEdgePassword'
        $ExchangeServer   = "exchange.contoso.com"

        $CredentialObject = New-Object -TypeName System.Management.Automation.PSCredential($UserId, $Password)

		Mock Write-OPDEventLog {}

		Mock Get-Command { $false }
	}

	BeforeEach {
        Mock Import-RemoteSession {
            @(
                @{
                    ExportedCommands = @{
                        'Get-ClientAccessService'    = 'Get-ClientAccessService'
                        'Enable-ExchangeCertificate' = 'Enable-ExchangeCertificate'
                    }
                }
            )
        }

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

		$rule = [RDExchangePowerShellCmdletsLoaded]::new([IDNoSession]::new())
	}

	Context "RDExchangePowerShellCmdletsLoaded" {
		It "Import of Exchange cmdlets successful" {
            $rule.Execute(@{Obj=$null;Credential=$CredentialObject;ExchangeServer=$ExchangeServer})

            $rule.Success           | Should -BeTrue
            $rule.Insight.Name      | Should -Be 'IDNoSession'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "Unable to establish a session with server (IDNoSession)" {
            Mock New-PSSession {}

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject;ExchangeServer=$ExchangeServer})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoSession'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f $ExchangeServer)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "Unable to import cmdlets from remote session (IDUnableToImportRemoteSession)" {
            Mock Import-RemoteSession {}

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject;ExchangeServer=$ExchangeServer})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDUnableToImportRemoteSession'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f $ExchangeServer)
            $rule.Insight.Action    | Should -Be ($global:InsightActions.($rule.Insight.Name) -f $ExchangeServer)
		}

		It "Exchange commands did not import from remote session (IDUnableToImportExchangeCmdlets)" {
            Mock Import-RemoteSession {
                @(
                    @{
                        ExportedCommands = @{
                            'Enable-ExchangeCertificate' = 'Enable-ExchangeCertificate'
                        }
                    }
                )
            }

            $rule.Execute(@{Obj=$null;Credential=$CredentialObject;ExchangeServer=$ExchangeServer})

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDUnableToImportExchangeCmdlets'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f $ExchangeServer)
            $rule.Insight.Action    | Should -Be ($global:InsightActions.($rule.Insight.Name) -f $ExchangeServer)
		}
	}
}