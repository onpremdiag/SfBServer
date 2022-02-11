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
# Filename: RDTestAppPrincipalExists.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/26/2020 4:00 PM
#
# Last Modified On: 10/28/2020 9:51 AM
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
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDUnableToConnectToAAD.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDServicePrincipalDoesNotExist.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDNoServicePrincipalNames.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDExternalWSNotInSPNList.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\MSOnlineMocks.ps1)

    . $sut
}

Describe -Tag 'SfBServer' "RDTestAppPrincipalExists" {
	Context "RDTestAppPrincipalExists" {
		BeforeAll {
            $ServiceName = "00000004-0000-0ff1-ce00-000000000000"

			Mock Write-OPDEventLog {}

            $global:OPDOptions = @(
                @{
                    AzureEnvironment = "AzureCloud"
                }
            )
        }

		BeforeEach {
            Mock Get-MsolServicePrincipalCredential { $true }

            Mock Get-MsolServicePrincipal {
                $list = New-Object "System.Collections.Generic.List[string]"
                $list.Add("https://sfb2019.contoso.com/")
                $list.Add("https://api.skypeforbusiness.com/")
                $list.Add("00000004-0000-0ff1-ce00-000000000000/lyncmx.com")
                $list.Add("00000004-0000-0ff1-ce00-000000000000/*.infra.lync.com")
                $list.Add("00000004-0000-0ff1-ce00-000000000000/*.online.lync.com")
                $list.Add("00000004-0000-0ff1-ce00-000000000000")
                $list.Add("Microsoft.Lync")

                $obj = New-Object PSObject
                Add-Member -InputObject $obj -MemberType NoteProperty "AppPrincipalName" -Value $ServiceName
                Add-Member -InputObject $obj -MemberType NoteProperty "ServicePrincipalNames" -Value $list

                $obj
            }

            Mock Get-CsService {
                New-Object PSObject -Property @{"ExternalFqdn"="sfb2019.contoso.com"}
            }

			$rule = [RDTestAppPrincipalExists]::new([IDUnableToConnectToAAD]::new())
		}

		It "No issues (Success)" {
            $rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.Insight.Name      | Should -Be 'IDUnableToConnectToAAD'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "Unable to connect to Azure Active Directory (IDUnableToConnectToAAD)" {
            Mock Connect-MsolService {$PSCmdlet.ThrowTerminatingError()}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDUnableToConnectToAAD'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "Service name does not exist (IDServicePrincipalDoesNotExist)" {
            Mock Get-MsolServicePrincipalCredential {}
            Mock Connect-MsolService {}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDServicePrincipalDoesNotExist'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "No service principal names found (IDNoServicePrincipalNames)" {
            Mock Get-MsolServicePrincipal {}
            Mock Connect-MsolService {}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoServicePrincipalNames'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "Web Service not found in list of SPNs (IDExternalWSNotInSPNList)" {
            Mock Connect-MsolService {}
            Mock Get-CsService {
                New-Object PSObject -Property @{"ExternalFqdn"="bozon.contoso.com"}
            }

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDExternalWSNotInSPNList'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}
	}
}