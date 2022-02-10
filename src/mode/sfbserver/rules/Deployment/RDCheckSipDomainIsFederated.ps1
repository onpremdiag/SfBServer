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
# Filename: RDCheckSipDomainIsFederated.ps1
# Description: Check to see if SIP domain is federated/managed
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 4/13/2021 12:09 PM
#
# Last Modified On: 4/13/2021 12:10 PM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckSipDomainIsFederated : RuleDefinition
{
    RDCheckSipDomainIsFederated([object] $Insight)
    {
        $this.Name        ='RDCheckSipDomainIsFederated'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('8266DBA5-5585-431D-9781-FDC01DCEB1B0')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference
        $SipAddress                 = Get-ParameterDefinition -Object $this -ParameterName 'PDSipAddress'

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            $Response = Invoke-WebRequest -Uri "https://login.microsoftonline.com/getuserrealm.srf?Login=$($SipAddress)" | ConvertFrom-Json

            if (-not [string]::IsNullOrEmpty($Response))
            {
                if ($Response.NameSpaceType -ne 'Managed' -and $Response.NameSpaceType -ne 'Federated')
                {
                    throw 'IDSipDomainNotFederated'
                }
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDSipDomainNotFederated
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                default
                {
                    $LogArguments = @{
                        LogName   = $global:EventLogName
                        Source    = "Rules"
                        EntryType = "Error"
                        Message   = $_
                        EventId   = 9002
                    }

                    Write-EventLog @LogArguments

                    $this.Success = $false
                }
            }
        }
        finally
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
        }
    }
}
