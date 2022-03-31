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
# Filename: ADCertificateCheck.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/13/2020 12:44 PM
#
# Last Modified On: 2/13/2020 12:45 PM
#################################################################################
Set-StrictMode -Version Latest

class ADCertificateCheck : AnalyzerDefinition
{
    ADCertificateCheck()
    {
        $this.Name        = 'ADCertificateCheck'
        $this.Description = $global:AnalyzerDescriptions.($this.Name)
        $this.Id          = [guid]::new('9E895D98-0E88-4FDD-AD7E-A9E83803E68E')
        $this.Success     = $true
        $this.Executed    = $false
        $this.EventId     = Get-EventId($this.Name)

        # Add the rules that this analyzer will use
        # https://uclobby.com/2015/06/19/checks-to-do-in-the-lync-sfb-certificate-store/
        #

        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDCheckMisplacedRootCACertificates]::new([IDLocalCertStoreNotFound]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDDuplicatesInTrustedRootCA]::new([IDDuplicatesInTrustedRootCA]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDCheckTooManyCertsRootCA]::new([IDNoCertificatesFound]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDCheckEdgeCerts]::new([IDEdgeCertsNotOnSan]::new()))
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentAnalyzer = $this.Id
        $id                     = Get-ProgressId
        $ruleCount              = 0

        $UserId           = Get-ParameterDefinition -Object $this -ParameterName 'PDEdgeUserID'
        $Password         = Get-ParameterDefinition -Object $this -ParameterName 'PDEdgePassword'
        $CredentialObject = New-Object -TypeName System.Management.Automation.PSCredential($UserId, $Password)

        try
        {
            foreach($rule in $this.RuleDefinitions)
            {
                $rule.ExecutionId          = $this.ExecutionId
                $rule.ParameterDefinitions = $this.ParameterDefinitions
                $ruleCount++

                Write-Progress -Activity $global:OPDStrings.'RunningRules' -Id $id -Status $rule.Description -PercentComplete ($ruleCount/$this.RuleDefinitions.Count*100)
                Invoke-Rule -rule $rule -Obj @{Obj=$obj;Credential=$CredentialObject}

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
            $this.Success  = $false
            $this.Executed = $false
            $this.Status   = [OPDStatus]::WARNING
        }
        catch [System.Management.Automation.Remoting.PSRemotingTransportException]
        {
            $this.ErrorMessage = "[{0}] - {1}" -f $this.Name, $_.ErrorDetails.Message
            Write-EventLog -LogName $global:EventLogName -Source "Analyzers" -EntryType Error -Message $this.ErrorMessage -EventId ($_.FullyQualifiedErrorId.split(',')[0]).Substring(1,5)

            $this.Success  = $false
            $this.Executed = $false
            $this.Status   = [OPDStatus]::WARNING
        }
        catch
        {
            Write-EventLog -LogName $global:EventLogName -source "Analyzers" -EntryType Error -Message ("{0}`r`n{1}" -f $_.Exception, $_.ScriptStackTrace) -EventId 999
            $this.Success  = $false
            $this.Executed = $false
            $this.Status   = [OPDStatus]::ERROR
        }
        finally
        {
            Write-Progress -Activity $global:OPDStrings.'RunningRules' -Id $id -Status "Ready" -Completed
        }
    }
}
