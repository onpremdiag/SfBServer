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
# Filename: RDCheckDocLibEmail.tests.ps1
# Description: <TODO>
# Owner: Stefan Goßner <stefang@microsoft.com>
# Created On: 8/09/2019 3:38 PM
#
# Last Modified On: 8/09/2019 3:38 PM
#################################################################################
Set-StrictMode -Version Latest

$sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
$srcRoot  = "$root\src"
$testRoot = "$root\OnPremDiagTests"
$testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
$mode     = $Matches.Mode

# Load resource files needed for tests
. "$testRoot\testhelpers\LoadResourceFiles.ps1"
Import-ResourceFiles -Root $srcRoot -MyMode $mode

. "$srcRoot\common\Globals.ps1"
. "$srcRoot\common\Utils.ps1"
. "$srcRoot\common\SQL.ps1"
. "$srcRoot\mode\$mode\common\Globals.ps1"
. "$srcRoot\mode\$mode\common\$mode.ps1"
. "$srcRoot\classes\RuleDefinition.ps1"
. "$srcRoot\classes\InsightDefinition.ps1"
. "$srcRoot\mode\$mode\insights\Admin\IDDocLibEmailNotInSync.ps1"
. "$srcRoot\mode\$mode\insights\Global\IDException.ps1"
. "$testRoot\mocks\SharePointMocks.ps1"

. $sut

Describe -Tag 'SharePoint' "RDCheckDocLibEmail" {
    Context "RDCheckDocLibEmail" {

        BeforeEach {
            Mock Write-OPDEventLog {}

            Mock Get-SPDatabase {
                return @(
                            @{
                                Type = "Content Database"
                                LegacyDatabaseConnectionString = "ContentDB_ConnStr"
                            },
                            @{
                                Type = "Configuration Database"
                                LegacyDatabaseConnectionString = "ConfigDB_ConnStr"
                            }
                        )
            }

            $rd = [RDCheckDocLibEmail]::new([IDDocLibEmailNotInSync]::new())
        }

        It "All Email addresses are in sync" {
            Mock Get-DataTableFromSQL {
                            @{
                                Alias = "mail_OK"
                                SiteId = [Guid]("11111111-1111-1111-1111-111111111111")
                                WebId = [Guid]("22222222-2222-2222-2222-222222222222")
                                ListId = [Guid]("33333333-3333-3333-3333-333333333333")
                            }
            } -ParameterFilter { $Connstr -eq "ContentDB_ConnStr" }

            Mock Get-DataTableFromSQL {
                            @{
                                Alias = "mail_OK"
                                SiteId = [Guid]("11111111-1111-1111-1111-111111111111")
                                WebId = [Guid]("22222222-2222-2222-2222-222222222222")
                                ListId = [Guid]("33333333-3333-3333-3333-333333333333")
                            }
            } -ParameterFilter { $Connstr -eq "ConfigDB_ConnStr" }

            $rd.Execute($null)
            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "Some Email addresses are out of sync between Config DB and Content DB" {
            Mock Get-DataTableFromSQL {
                            @{
                                Alias = "mail_OK"
                                SiteId = [Guid]("11111111-1111-1111-1111-111111111111")
                                WebId = [Guid]("22222222-2222-2222-2222-222222222222")
                                ListId = [Guid]("33333333-3333-3333-3333-333333333333")
                            }
            } -ParameterFilter { $Connstr -eq "ContentDB_ConnStr" }

            Mock Get-DataTableFromSQL {
                            @{
                                Alias = "mail_WRONG"
                                SiteId = [Guid]("11111111-1111-1111-1111-111111111111")
                                WebId = [Guid]("22222222-2222-2222-2222-222222222222")
                                ListId = [Guid]("33333333-3333-3333-3333-333333333333")
                            }
            } -ParameterFilter { $Connstr -eq "ConfigDB_ConnStr" }

            Mock Get-UrlForList { "http://listUrl" }

            $rd.Execute($null)
            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should Not Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should Not Be $global:InsightActions.($rd.Insight.Name)
        }
    }
}