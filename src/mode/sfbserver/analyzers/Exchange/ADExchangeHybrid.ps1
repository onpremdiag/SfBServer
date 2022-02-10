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
# Filename: ADExchangeHybrid.ps1
# Description: Verifies that hybrid configuration is correct
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/27/2020 3:10 PM
#
# Last Modified On: 10/27/2020 3:10 PM
#################################################################################
Set-StrictMode -Version Latest

class ADExchangeHybrid : AnalyzerDefinition
{
    ADExchangeHybrid()
    {
        $this.Name        = 'ADExchangeHybrid'
        $this.Description = $global:AnalyzerDescriptions.($this.Name)
        $this.Id          = [guid]::new('DBA0B09E-CD3B-49D0-9B62-6123A829C5C0')
        $this.Success     = $true
        $this.Executed    = $false
        $this.EventId     = Get-EventId($this.Name)

        # Add the rules that this analyzer will use
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDExchangePowerShellCmdletsLoaded]::new([IDNoSession]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDTestExchangeCertificateForAutodiscover]::new([IDUnableToGetRemoteCertificate]::new()))

        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDTestAppPrincipalExists]::new([IDUnableToConnectToAAD]::new())) #Connect-MsolService
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDTestAutoDiscover]::new([IDAutoDiscoverNameDoNotMatch]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDAutoDiscoverServiceInternalUri]::new([IDNoClientAccessServerRole]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDExchangeAutodiscoverUrl]::new([IDNoOauthConfigurationFound]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDCsPartnerApplication]::new([IDNoPartnerApplication]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDOAuthCertificateValid]::new([IDOAuthCertficateExpired]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDTestOAuthServerConfiguration]::new([IDNoOAuthServer]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDTestPartnerApplication]::new([IDNoPartnerApplication]::new()))
        Add-RuleDefinition -Analyzer $this -RuleDefinition ([RDTestExchangeConnectivity]::new([IDNoSIPAddress]::new()))
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentAnalyzer = $this.Id
        $id                     = Get-ProgressId
        $ruleCount              = 0
        $session                = $null
        $ExchangeServer         = Get-ParameterDefinition -Object $this -ParameterName 'PDExchangeServer'
        $CredentialObject       = Get-Credential -Message "Enter Exchange management credentials"

        try
        {
            foreach($rule in $this.RuleDefinitions)
            {
                $rule.ExecutionId          = $this.ExecutionId
                $rule.ParameterDefinitions = $this.ParameterDefinitions
                $ruleCount++

                Write-Progress -Activity $global:OPDStrings.'RunningRules' -Id $id -Status $rule.Description -PercentComplete ($ruleCount/$this.RuleDefinitions.Count*100)
                Invoke-Rule -rule $rule -Obj @{Obj=$obj;Credential=$CredentialObject;ExchangeServer=$ExchangeServer}

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
            switch($_.ToString())
            {
                default
                {
                    $LogArguments = @{
                        LogName = $global:EventLogName
                        Source = "Analyzers"
                        EntryType = "Error"
                        Message = $_
                        EventId = 999
                    }

                    Write-EventLog @LogArguments
                    $this.success = $false
                    $this.Status = [OPDStatus]::ERROR
                }
            }
        }
        finally
        {
            Write-Progress -Activity $global:OPDStrings.'RunningRules' -Id $id -Status "Ready" -Completed
        }
    }
}
