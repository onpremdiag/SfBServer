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
# Filename: RDServerCores.ps1
# Description: Determines the number of CPU cores available are correct
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/25/2022 12:13:13 PM
#
#################################################################################
Set-StrictMode -Version Latest

class RDServerCores : RuleDefinition
{
    RDServerCores([object] $Insight)
    {
        $this.Name        ='RDServerCores'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('5BE33E7B-C5C5-4284-A6A8-D1E8B79FF22C')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference

        try
        {
            $Processor = Get-WmiObjectHandler -Class Win32_Processor

            if ($Processor.NumberOfCores -lt 6)
            {
                $CurrentProduct = Get-CsServerVersion
                if ($CurrentProduct -match "^(?<Product>.*)\((?<Version>\d+\.\d+\.\d+\.\d+)\):(?<License>.*$)")
                {
                    $Product = $Matches.Product
                }

                throw 'IDInsufficientCores'
            }
        }
        catch
        {
            switch ($_.ToString())
            {
                IDInsufficientCores
                {
                    switch -Wildcard ($Product)
                    {
                        '*2015*'
                        {
                            $this.Insight.Name      = 'IDInsufficientCores2015'
                            $this.Insight.Action    = $global:InsightActions.'IDInsufficientCores2015'
                            $this.Insight.Detection = ($global:InsightDetections.'IDInsufficientCores2015' -f $Processor.NumberOfCores, 6)
                        }

                        '*2019*'
                        {
                            $this.Insight.Name      = 'IDInsufficientCores2019'
                            $this.Insight.Action    = $global:InsightActions.'IDInsufficientCores2019'
                            $this.Insight.Detection = ($global:InsightDetections.'IDInsufficientCores2019' -f $Processor.NumberOfCores, 6)
                        }

                        default
                        {
                            $this.Insight.Name      = 'IDInsufficientCores'
                            $this.Insight.Action    = $global:InsightActions.'IDInsufficientCores'
                            $this.Insight.Detection = $global:InsightDetections.'IDInsufficientCores'
                        }

                    }

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
