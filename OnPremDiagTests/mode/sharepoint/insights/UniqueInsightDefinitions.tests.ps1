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
# Filename: UniqueInsightDefinitions.tests.ps1
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

    . "$srcRoot\common\utils.ps1"
    . "$srcRoot\classes\InsightDefinition.ps1"
}

Describe -Tag 'SharePoint' "UniqueInsightDefinitions" {
    BeforeAll {
        #$insightIds = [Collections.Generic.SortedDictionary[string, int]] @{}

        $insights = Get-ChildItem -Path "$srcRoot\mode\$mode\insights" -Recurse -Filter ID*.ps1
        $insights | ForEach-Object {. $_.FullName}
    }

    Context "There should be no TODO" {
        It "Insights should have no TODO"  {
            foreach($insight in $insights)
            {
                $contents = Get-Content -Path $insight.FullName
                foreach($line in $contents)
                {
                    if ($line.contains("TODO"))
                    {
                        $foundIt = $true
                        break
                    }
                    else
                    {
                        $foundIt = $false
                    }
                }
                $foundIt | Should -BeFalse
            }
        }
    }

    Context "Should have constructors" {
        It "Default constructor should not be empty" {
            foreach($insight in $insights)
            {
                $fc = Get-Content -Path $insight.FullName
                $fc | Select-String -Pattern "^\s+$($insight.BaseName)\(\)$" | Should -Not -BeNullOrEmpty
            }
        }

        It "Overloaded constructor for with Status should not be empty" {
            foreach($insight in $insights)
            {
                $fc = Get-Content -Path $insight.FullName
                $fc | Select-String -Pattern ('^\s+{0}\(\[OPDStatus\]\s+\$Status\)$' -f $insight.BaseName) | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context "Insight status should be initialized to Failure/Error state" {
        It "Insight status should be initialized to Failure/Error state" {
            foreach($insight in $insights)
            {
                $insightDefinition = New-Object -TypeName $insight.BaseName
                $insightDefinition.Status | Should -BeIn @('ERROR','WARNING')
            }
        }
    }

    Context "Insights should have an ID assigned to them" {
        It "Insights should have an ID assigned" {
            foreach($insight in $insights)
            {
                $insightDefinition = New-Object -TypeName $insight.BaseName
                $insightDefinition.Id | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context "Insights should have a detection defined" {
        It "Insights should have a detection" {
            foreach($insight in $insights)
            {
                $insightDefinition = New-Object -TypeName $insight.BaseName
                $insightDefinition.Detection | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context "Insights should have an action defined" {
        It "Insights should have an action" {
            foreach($insight in $insights)
            {
                $insightDefinition = New-Object -TypeName $insight.BaseName
                $insightDefinition.Action | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context "Class names should match the base name of the script" {
        It "Insight class names should match script base name" {
            foreach($insight in $insights)
            {
                $insightDefinition = New-Object -TypeName $insight.BaseName
                $insightDefinition.Name | Should -Be $insight.BaseName
            }
        }
    }

    Context "Insight IDs should be unique" {
        It "Insight Id should be unique" {
            $insightIds = [Collections.Generic.SortedDictionary[string, int]] @{}

            foreach($insight in $insights)
            {
                #. $insight.FullName

                $i = New-Object -TypeName $insight.Basename

                # Is the id already present?
                If ($insightIds.ContainsKey($i.Id))
                {
                    $insightIds[$i.Id] += 1
                }
                else
                {
                    $insightIds.Add($i.Id, 1)
                }
            }

            $insightIds.Values | ForEach-Object {$_ | Should -Be 1}
        }
    }
}