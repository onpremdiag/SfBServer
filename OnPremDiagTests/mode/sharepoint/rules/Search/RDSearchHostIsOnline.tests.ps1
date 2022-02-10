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
# Filename: RDSearchHostIsOnline.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 6/13/2019 1:59 PM
#
# Last Modified On: 6/13/2019 1:59 PM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
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
    . "$srcRoot\mode\$mode\common\Globals.ps1"
    . "$srcRoot\mode\$mode\common\$mode.ps1"
    . "$srcRoot\classes\RuleDefinition.ps1"
    . "$srcRoot\classes\InsightDefinition.ps1"
    . "$testRoot\mocks\SharePointMocks.ps1"
    . "$srcRoot\mode\$mode\insights\search\IDSearchHostIsOffline.ps1"
    . "$srcRoot\mode\$mode\rules\search\RDSearchHostIsOnline.ps1"
}

Describe -Tag 'SharePoint' "RDSearchHostIsOnline" {
    Context "Testing all servers in the collection" {
        BeforeAll {
            Mock Confirm-SharePointSnapinsAreLoaded {$true}
            Mock Write-OPDEventLog {}

            $rd = [RDSearchHostIsOnline]::new([IDSearchHostIsOffline]::new())

            $searchHosts = @(
                @{
                    Status = "Online"
                    Server = @{
                        Name = "SERVER01"
                        Status = "Online"
                    }
                },
                @{
                    Status = "Online"
                    Server = @{
                        Name = "SERVER02"
                        Status = "Online"
                    }
                },
                @{
                    Status = "Disabled"
                    Server = @{
                        Name = "SERVER03"
                        Status = "Disabled"
                    }
                },
                @{
                    Status = "Disabled"
                    Server = @{
                        Name = "SERVER04"
                        Status = "Disabled"
                    }
                }
            )

            $onlineServers  = $searchHosts | Where-Object {$_.Server.Status -eq "Online"}
            $offlineServers = $searchHosts | Where-Object {$_.Server.Status -ne "Online"}
        }

        It "Server should be online" {
        foreach ($server in $searchHosts)
        {
            $insightDetection = $rd.Insight.Detection

            $rd.Execute($server)

            if ($server.Server.Status -eq "Online")
            {
                $rd.Success | Should -BeTrue
            }
            else
            {
                $insightText = $insightDetection -f $server.Server.Name
                $rd.Insight.Detection | Should -Be $insightText
            }
        }
    }
    }
}