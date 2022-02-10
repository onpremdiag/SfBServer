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
# Filename: RDServerMemory.ps1
# Description: Determine if the server meets the minimum required memory
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/26/2022 9:41:16 AM
#
#################################################################################
Set-StrictMode -Version Latest

class RDServerMemory : RuleDefinition
{
    RDServerMemory([object] $Insight)
    {
        $this.Name        ='RDServerMemory'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('26CDF524-F8DE-447E-8246-351FDC486EB5')
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
            $Memory = Get-WmiObjectHandler -Class Win32_ComputerSystem |
                Select-Object @{N="Memory";E={[math]::Round($_.TotalPhysicalMemory/(1GB))}},
                NumberOfProcessors, NumberOfLogicalProcessors

            $CurrentProduct = Get-CsServerVersion
            if ($CurrentProduct -match "^(?<Product>.*)\((?<Version>\d+\.\d+\.\d+\.\d+)\):(?<License>.*$)")
            {
                $Product = $Matches.Product

                if ($Product -like '*2015*')
                {
                    $MinimumMemory = 32
                }
                elseif ($Product -like '*2019*')
                {
                    $MinimumMemory = 64
                }
                else
                {
                    throw 'IDUnknownProduct'
                }
            }
            else
            {
                throw 'IDUnknownProduct'
            }

            if ($Memory.Memory -lt $MinimumMemory)
            {
                throw 'IDInsufficientMemory'
            }
        }
        catch
        {
            switch ($_.ToString())
            {
                IDUnknownProduct
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Action    = $global:InsightActions.$_
                    $this.Insight.Detection = ($global:InsightDetections.$_ -f $CurrentProduct)
                    $this.Success           = $false
                }

                IDInsufficientMemory
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.$_ -f $MinimumMemory, $Memory)
                    $this.Success           = $false

                    switch -Wildcard ($Product)
                    {
                        '*2015*'
                        {
                            $this.Insight.Name      = 'IDInsufficientMemory2015'
                            $this.Insight.Detection = ($global:InsightDetections.'IDInsufficientMemory2015' -f $MinimumMemory, $Memory.Memory)
                            $this.Insight.Action    = $global:InsightActions.'IDInsufficientMemory2015'
                        }

                        '*2019*'
                        {
                            $this.Insight.Name      = 'IDInsufficientMemory2019'
                            $this.Insight.Detection = ($global:InsightDetections.'IDInsufficientMemory2019' -f $MinimumMemory, $Memory.Memory)
                            $this.Insight.Action    = $global:InsightActions.'IDInsufficientMemory2019'
                        }
                    }
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
