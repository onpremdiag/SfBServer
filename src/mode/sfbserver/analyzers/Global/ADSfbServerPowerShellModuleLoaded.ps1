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
# Filename: ADSfbServerPowerShellModuleLoaded.ps1
# Description: Verifies that the Skype for Business snap-in is loaded
# Owner: Jo�o Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class ADSfbServerPowerShellModuleLoaded : AnalyzerDefinition
{
    ADSfbServerPowerShellModuleLoaded()
    {
        $this.Name        = 'ADSfbServerPowerShellModuleLoaded'
        $this.Description = $global:AnalyzerDescriptions.($this.Name)
        $this.Id          = [guid]::new('aa587492-57ed-4b69-b1b4-9bf8b2b44bec')
        $this.Success     = $true
        $this.Executed    = $false
        $this.EventId     = Get-EventId($this.Name)

        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDSfbServerPowerShellModuleLoaded]::new([IDSfbServerPowerShellModuleNotLoaded]::new()))
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentAnalyzer = $this.Id
        $id                     = Get-ProgressId
        $ruleCount              = 0

        try
        {
            foreach($rule in $this.RuleDefinitions)
            {
                $rule.ExecutionId          = $this.ExecutionId
                $rule.ParameterDefinitions = $this.ParameterDefinitions
                $ruleCount++

                Write-Progress -Activity $global:OPDStrings.'RunningRules' `
                               -Id $id `
                               -Status $rule.Description `
                               -PercentComplete ($ruleCount/$this.RuleDefinitions.Count*100)

                Invoke-Rule -rule $rule -Obj $Obj

                $this.Success = $this.Success -band $rule.Success

                if($false -eq $rule.Success)
                {
                    $this.Results += $rule
                }
            }

            $this.Executed = $true
        }
        catch
        {
            Write-EventLog  -LogName $global:EventLogName `
                            -source "Analyzers" `
                            -EntryType Error `
                            -Message ("{0}`r`n{1}" -f $_.Exception, $_.ScriptStackTrace) `
                            -EventId 999
            $this.Executed = $false
            $this.Success  = $false
            $this.Status   = [OPDStatus]::ERROR
        }
        finally
        {
            Write-Progress -Activity $global:OPDStrings.'RunningRules' -Id $id -Status "Ready" -Completed
        }
    }
}
