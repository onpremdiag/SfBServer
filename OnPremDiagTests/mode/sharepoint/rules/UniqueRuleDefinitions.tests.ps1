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
# Filename: UniqueRuleDefinitions.tests.ps1
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
    . "$srcRoot\classes\RuleDefinition.ps1"
    . "$srcRoot\classes\InsightDefinition.ps1"
    . "$testRoot\mocks\SharePointMocks.ps1"
    . "$testRoot\mocks\IISMocks.ps1"
}

Describe -Tag 'SharePoint' "UniqueRuleDefinitions" {
    BeforeAll {
        $insights  = Get-ChildItem $srcRoot\mode\$mode\insights -Recurse -Filter ID*.ps1 | ForEach-Object {. $_.FullName}
        $rules     = Get-ChildItem -Path "$srcRoot\mode\$mode\rules" -Recurse -Filter RD*.ps1

        $rules | ForEach-Object {. $_.FullName}
    }

    Context "There should be no TODO" {
        It "Rules should have no TODO" {
            foreach($rule in $rules)
            {
                $contents = Get-Content -Path $rule.FullName
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

    Context "Check for ID assignment" {
        It "Rules should have an ID assigned" {
            foreach($rule in $rules)
            {
                $ruleDefinition = New-Object -TypeName $rule.BaseName -ArgumentList (New-Object PSCustomObject)
                $ruleDefinition.Id | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context "Check for EventID assignment" {
        It "Rules should have an EventID assigned" {
            foreach($rule in $rules)
            {
                $ruleDefinition = New-Object -TypeName $rule.BaseName -ArgumentList (New-Object PSCustomObject)
                $ruleDefinition.EventId | Should -BeGreaterThan 0
            }
        }
    }

    Context "Execution ID should be initialized to empty GUID" {
        It "Rules should have an empty ExecutionId" {
            foreach($rule in $rules)
            {
                $ruleDefinition = New-Object -TypeName $rule.BaseName -ArgumentList (New-Object PSCustomObject)
                $ruleDefinition.ExecutionId | Should -Be ([guid]::Empty)
            }
        }
    }

    Context "Class names should match the basename of the file" {
        It "Rule names should match script base name" {
            foreach($rule in $rules)
            {
                $ruleDefinition = New-Object -TypeName $rule.BaseName -ArgumentList (New-Object PSCustomObject)
                $ruleDefinition.Name | Should -Be $rule.BaseName
            }
        }
    }

    Context "All Rules should be initialized to true" {
        It "Rule success should be initialized to true" {
            foreach($rule in $rules)
            {
                $ruleDefinition = New-Object -TypeName $rule.BaseName -ArgumentList (New-Object PSCustomObject)
                $ruleDefinition.Success | Should -BeTrue
            }
        }
    }

    Context "Rules should have a unique ID " {
        It "Rule IDs should be unique" {
            $ruleIds = [Collections.Generic.SortedDictionary[string,int]] @{}

            foreach($rule in $rules)
            {
                . $rule.FullName

                $ruleDefinition = New-Object -TypeName $rule.BaseName -ArgumentList (New-Object PSCustomObject)

                if ($ruleIds.ContainsKey($ruleDefinition.Id))
                {
                    $ruleIds[$ruleDefinition.Id] += 1
                }
                else
                {
                    $ruleIds.Add($ruleDefinition.Id, 1)
                }
            }

            $ruleIds.Values | ForEach-Object {$_ | Should -Be 1}
        }
    }

    Context "Check to make sure event id in the correct range" {
        It "Rule EventIDs need to be unique and valid" {
            $ruleEventIds = [Collections.Generic.SortedDictionary[uint16,int]] @{}

            foreach($rule in $rules)
            {
                # Source in the rule definition
                . $rule.FullName

                $r =  New-Object -TypeName $rule.BaseName -ArgumentList (New-Object PSCustomObject)

                # we do not enforce an event ID right now
                if ($r.EventId -gt 0)
                {
                    # Is the id already present?
                    if ($ruleEventIds.ContainsKey($r.EventId))
                    {
                        $ruleEventIds[$r.EventId] += 1
                    }
                    else
                    {
                        $ruleEventIds.Add($r.EventId, 1)
                    }
                }
            }

            foreach ($key in $ruleEventIds.Keys)
            {
                $key | Should -BeGreaterOrEqual 9500
                $key | Should -BeLessThan 9700
                $ruleEventIds[$key] | Should -Be 1 -Because "$key is not a unique EventID"
            }
        }
    }

    Context "Check for description" {
        It "Rule should have a description" {
            foreach($rule in $rules)
            {
                $ruleDefinition = New-Object -TypeName $rule.BaseName -ArgumentList (New-Object PSCustomObject)
                $ruleDefinition.Description | Should -Not -BeNullOrEmpty
            }
        }

        It "Rule should not have a Detection" {
            foreach($rule in $rules)
            {
            $ruleDefinition = New-Object -TypeName $rule.BaseName -ArgumentList (New-Object PSCustomObject)
            $ruleDefinition.Detection | Should -BeNullOrEmpty
            }
        }
    }
}