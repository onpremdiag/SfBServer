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
# Filename: ADCompareOnPremToOnline.ps1
# Description: Verifies the OnPrem values match the OnLine values
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/21/2020 1:25 PM
#
# Last Modified On: 1/21/2020 1:25 PM
#################################################################################
Set-StrictMode -Version Latest

class ADCompareOnPremToOnline : AnalyzerDefinition
{
    ADCompareOnPremToOnline()
    {
        $this.Name        = 'ADCompareOnPremToOnline'
        $this.Description = $global:AnalyzerDescriptions.($this.Name)
        $this.Id          = [guid]::new('790FD6D8-6B1B-4EF7-A99E-B180ACB4AB20')
        $this.Success     = $true
        $this.Executed    = $false
        $this.EventId     = Get-EventId($this.Name)

        # Add the rules that this analyzer will use
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDCompareAllowedDomains]::new([IDOnlineOnPremAllowedDomainDoNotMatch]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDAllowFederatedPartners]::new([IDDoNotAllowAllFederatedPartners]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDAllowFederatedUsers]::new([IDDoNotAllowAllFederatedUsers]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDSharedSipAddressSpace]::new([IDDoNotAllowSharedSipAddressSpace]::new()))
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentAnalyzer = $this.Id
        $id                     = Get-ProgressId
        $ruleCount              = 0

        # Need to import cmdlets for the analyzer session
        try
        {
            $SfBSession       = Get-PSSession -Name "O365Domain"

            # Let's see if we've already got the cmdlets from earlier in the invocation
            if (-not (Get-Command -Name Get-CsTenant -ErrorAction SilentlyContinue))
            {
                Import-PSSession -Session $SfBSession -CommandName Get-CsTenant, Get-CsTenantFederationConfiguration -AllowClobber | Out-Null
            }

            foreach($rule in $this.RuleDefinitions)
            {
                $rule.ExecutionId          = $this.ExecutionId
                $rule.ParameterDefinitions = $this.ParameterDefinitions
                $ruleCount++

                Write-Progress -Activity $global:OPDStrings.'RunningRules' -Id $id -Status $rule.Description -PercentComplete ($ruleCount/$this.RuleDefinitions.Count*100)
                Invoke-Rule -rule $rule -Obj $obj

                $this.Success = $this.Success -band $rule.Success

                if($false -eq $rule.Success)
                {
                    $this.Results += $rule
                    break
                }
            }

            $this.Executed = $true
        }
        catch [System.Net.WebException]
        {
            Write-EventLog -LogName $global:EventLogName -source "Analyzers" -EntryType Error -Message ("{0}`r`n{1}" -f $_.Exception, $_.ScriptStackTrace) -EventId 999
            $this.Success = $false
            $this.Executed = $false
            $this.Status = [OPDStatus]::WARNING
        }
        catch [System.Management.Automation.Remoting.PSRemotingTransportException]
        {
            $this.ErrorMessage = "[{0}] - {1}" -f $this.Name, $_.ErrorDetails.Message
            Write-EventLog -LogName $global:EventLogName -Source "Analyzers" -EntryType Error -Message $this.ErrorMessage -EventId ($_.FullyQualifiedErrorId.split(',')[0]).Substring(1,5)

            $this.Success  = $false
            $this.Executed = $false
            $this.Status = [OPDStatus]::WARNING
        }
        catch
        {
            Write-EventLog -LogName $global:EventLogName -source "Analyzers" -EntryType Error -Message ("{0}`r`n{1}" -f $_.Exception, $_.ScriptStackTrace) -EventId 999
            $this.Success = $false
            $this.Executed = $false
            $this.Status = [OPDStatus]::ERROR
        }
        finally
        {
            Write-Progress -Activity $global:OPDStrings.'RunningRules' -Id $id -Status "Ready" -Completed
        }
    }
}
