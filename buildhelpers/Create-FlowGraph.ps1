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
# Filename: Create-FlowGraph.ps1
# Description: <TODO>
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 7/15/2021 10:35 AM
#
#################################################################################
[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [String]
    $Source,

    [Parameter(Mandatory=$true)]
    [String]
    $Product,

    [Parameter(Mandatory=$false)]
    [String]
    $Output = (Join-Path -Path $Source -ChildPath "mode\$($Product)\BuildArtifacts")
)

function New-MermaidDefinition
{
    param
    (
        [Parameter(Mandatory=$true)]
        [object]
        $Scenario
    )

    $sd = New-Object -TypeName System.Text.StringBuilder

    $sd.AppendLine("::: mermaid") | Out-Null
    $sd.AppendLine("graph LR") | Out-Null
    $sd.AppendLine() | Out-Null
    $sd.AppendLine("Parameter1[\Parameter1\] -.-> Scenario(Scenario)") | Out-Null
    $sd.AppendLine("Parameter2[\Parameter2\] -.-> Scenario(Scenario)") | Out-Null
    $sd.AppendLine("Parameter3[\Parameter3\] -.-> Scenario(Scenario)") | Out-Null

    $sd.AppendLine("Scenario --> Analyzer1(Analyzer1)") | Out-Null
    $sd.AppendLine("Analyzer1 --> Rule1(Rule1)") | Out-Null

    $sd.AppendLine("Rule1 --> Insight1(Insight1)") | Out-Null
    $sd.AppendLine("Rule1 --> Insight2(Insight2)") | Out-Null

    $sd.AppendLine("Insight1 --> Detection(Detection)") | Out-Null
    $sd.AppendLine("Insight1 --> Action(Action)") | Out-Null
    $sd.AppendLine("Insight2 --> ...(...)") | Out-Null

    $sd.AppendLine(":::") | Out-Null
    $sd.AppendLine("___") | Out-Null

    $sd.AppendLine("::: mermaid") | Out-Null
    $sd.AppendLine("graph LR") | Out-Null
    $sd.AppendLine() | Out-Null

    $sd.AppendLine("%%") | Out-Null
    $sd.AppendLine("%% Scenario Name: {0}" -f $Scenario) | Out-Null
    $sd.AppendLine("%% Date Generated: {0}" -f (Get-Date)) | Out-Null
    $sd.AppendLine("%% This file is autogenerated. Please do not edit directly") | Out-Null
    $sd.AppendLine("%%") | Out-Null
    $sd.AppendLine() | Out-Null

    $analyzerCount = 0

    # Output any parameter definitions next
    foreach($parameter in $Scenario.ParameterDefinitions)
    {
        $sd.AppendLine(("`t{0}[\{1}\] -.-> {2}" -f $parameter.Name, $parameter.Name, $Scenario.Name)) | Out-Null
    }
    $sd.AppendLine() | Out-Null

    foreach($analyzer in ($Scenario.AnalyzerDefinitions | Sort-Object -Property Name))
    {
        $analyzerCount++

        if ($analyzerCount -eq 1)
        {
            $sd.AppendLine(("`t{0}({1}) --{2}--> {3}[{4}]" -f $Scenario.Name , $Scenario.Name, $analyzerCount, $analyzer.Name, $analyzer.Name)) | Out-Null
        }
        else
        {
            $sd.AppendLine(("`t{0} --{1} --> {2}[{3}]" -f $Scenario.Name, $analyzerCount, $analyzer.Name, $analyzer.Name)) | Out-Null
        }
        $sd.AppendLine() | Out-Null

        $ruleCount = 0

        foreach($rule in ($analyzer.RuleDefinitions | Sort-Object -Property Name))
        {
            $ruleCount++
            $sd.AppendLine(("`t{0} -- {1}.{2} --> {3}[{4}]" -f $analyzer.Name, $analyzerCount, $ruleCount, $rule.Name, $rule.Name)) | Out-Null
        }
    }

    $sd.AppendLine() | Out-Null
    $sd.AppendLine(":::") | Out-Null

    $sd.ToString() | Write-Verbose

    return $sd.ToString()
}

function New-MessagesDefinition
{
    $str = New-Object -TypeName System.Text.StringBuilder

    $str.AppendLine("# Messages") | Out-Null
    $str.AppendLine("When particular rule detects an issue (return value is false) an **Insight detection** ") | Out-null
    $str.AppendLine("and an **Insight Action** are displayed in addition to an **Analyzer message** and **Rule description**.") | Out-Null
    $str.AppendLine("For more details, see example below:") | Out-null
    $str.AppendLine() | Out-Null
    $str.AppendLine("(...)") | Out-Null
    $str.AppendLine("- ***[TODO]***") | Out-Null
    $str.AppendLine() | Out-Null
    $str.AppendLine("(...)") | Out-Null

    $str.ToString() | Write-Verbose

    return $str.ToString()
}

function New-ScenarioDescription
{
    param
    (
        [Parameter()]
        [object]
        $Scenario
    )

    $str = New-Object -TypeName System.Text.StringBuilder

    $str.AppendLine("### Scenario Description") | Out-Null
    $str.AppendLine("| **Language** | **Name** | **Description** |") | Out-Null
    $str.AppendLine("|:----------|:------|:-------------|") | Out-Null

    $str.AppendLine(("| {2} | {0} | {1}" -f $Scenario.Name, $Scenario.Description, $OriginalCulture)) | Out-Null

    $str.ToString() | Write-Verbose

    return $str.ToString()
}

function New-ParameterDescription
{
    param
    (
        [Parameter()]
        [object]
        $Scenario
    )

    $str = New-Object -TypeName System.Text.StringBuilder
    $parameters = @()

    if(-not [string]::IsNullOrEmpty($Scenario.ParameterDefinitions))
    {
        $str.AppendLine("### Parameter description, prompt and example") | Out-Null
        $str.AppendLine("| **#** | **Language** | **Name** | **Description** | **Prompt** | **Example** |") | Out-Null
        $str.AppendLine("|:------|:----------|:------|:-------------|:----- |:-----|") | Out-Null

        foreach($parameter in $Scenario.ParameterDefinitions)
        {
            $parameters += $parameter
        }

        $index = 1
        foreach($parameter in ($parameters | Sort-Object -Property Name -Unique))
        {
            $str.AppendLine(("| P{4} | {5} | {0} | {1} | {2} | {3} |" -f $parameter.Name,$parameter.Description, $parameter.Prompt,$parameter.ExampleInputText, $index++, $OriginalCulture)) | Out-Null
        }
    }

    $str.ToString() | Write-Verbose

    return $str.ToString()
}

function New-AnalyzerDescription
{
    param
    (
        [Parameter()]
        [object]
        $Scenario
    )

    $str = New-Object -TypeName System.Text.StringBuilder
    $analyzers = @()

    if(-not [string]::IsNullOrEmpty($Scenario.AnalyzerDefinitions))
    {
        $str.AppendLine("### Analyzer Descriptions") | Out-Null
        $str.AppendLine("| **#** | **Language** | **Name** | **Description** | ") | Out-Null
        $str.AppendLine("|:------|:----------|:------|:-------------|") | Out-Null

        foreach($analyzer in $Scenario.AnalyzerDefinitions)
        {
            $analyzers += $analyzer
        }

        $index = 1
        foreach($analyzer in ($analyzers | Sort-Object -Property Name -Unique))
        {
            $str.AppendLine(("| A{2} | {3} | {0} | {1}|" -f $analyzer.Name, $analyzer.Description, $index++, $OriginalCulture)) | Out-Null
        }
    }

    $str.ToString() | Write-Verbose

    return $str.ToString()
}

function New-RuleDescription
{
    param
    (
        [Parameter()]
        [object]
        $Scenario
    )

    $str   = New-Object -TypeName System.Text.StringBuilder
    $rules = @()

    foreach ($analyzer in $Scenario.AnalyzerDefinitions)
    {
        foreach($rule in $analyzer.RuleDefinitions)
        {
            $rules += $rule
        }
    }

    if ($rules.Count -gt 0)
    {
        $str.AppendLine("### Rule Descriptions") | Out-Null
        $str.AppendLine("| **#** | **Language** | **Name** | **Description** | ") | Out-Null
        $str.AppendLine("|:------|:---------|:-----|:------------|") | Out-Null

        $index = 1
        foreach($rule in ($rules | Sort-Object -Property Name -Unique))
        {
            $str.AppendLine(("| R{2} | {3} | {0} | {1} |" -f $rule.Name, $rule.Description, $index++, $OriginalCulture)) | Out-Null
        }

        $str.ToString() | Write-Verbose
    }

    return $str.ToString()
}

function New-RuleSpecification
{
    param
    (
        [Parameter()]
        [object]
        $Scenario
    )

    $str = New-Object -TypeName System.Text.StringBuilder

    $str.AppendLine("# Rule specifications") | Out-Null

    $rules = @()

    foreach ($analyzer in $Scenario.AnalyzerDefinitions)
    {
        foreach($rule in ($analyzer.RuleDefinitions | Sort-Object -Property Name))
        {
            $rules += $rule
        }
    }

    $index = 1
    foreach($rule in ($rules | Sort-Object -Property Name -Unique))
    {
        $str.AppendLine(("### R{1} - {0} " -f $rule.Name, $index++)) | Out-Null
        $str.AppendLine(("- {0}" -f $rule.Description)) | Out-Null
        $str.AppendLine("***[TODO:Rule specification goes here]***") | Out-Null
        $str.AppendLine() | Out-Null
    }

    $str.ToString() | Write-Verbose

    return $str.ToString()
}

function New-InsightDetectionDescription
{
    param
    (
        [Parameter()]
        [object]
        $Scenario
    )

    $str = New-Object -TypeName System.Text.StringBuilder
    $insights = @()

    foreach ($analyzer in $Scenario.AnalyzerDefinitions)
    {
        foreach($rule in $analyzer.RuleDefinitions)
        {
            $fileName = ($Targets | Where-Object {$_.Name -eq $rule.Name}).Value.FullName

            if (Test-Path -Path $fileName)
            {
                $contents = Get-Content -Path $fileName
                $exceptions = $contents | Select-String -Pattern "^\s+.*throw"
                foreach($exception in $exceptions)
                {
                    if ($exception -match "^.*throw\s+'(?<Insight>ID\w+)'.*$")
                    {
                        $insights += $Matches.Insight
                    }
                }
            }
        }
    }

    if ($insights.Count -gt 0)
    {
        $str.AppendLine("### Insight detection descriptions") | Out-Null
        $str.AppendLine("| **#** | **Language** | **Name** | **Description** | ") | Out-Null
        $str.AppendLine("|:------|:---------|:-----|:------------|") | Out-Null

        $index = 1
        foreach($insight in ($insights | Sort-Object -Unique))
        {
            $str.AppendLine(("| ID{2} | {3} | {0} | {1} |" -f $insight, $global:InsightDetections.$insight, $index++, $OriginalCulture)) | Out-Null
        }

        $str.ToString() | Write-Verbose
    }

    return $str.ToString()
}

function New-InsightActionDescription
{
    param
    (
        [Parameter()]
        [object]
        $Scenario
    )

    $str = New-Object -TypeName System.Text.StringBuilder

    $insights = @()

    foreach ($analyzer in $Scenario.AnalyzerDefinitions)
    {
        foreach($rule in $analyzer.RuleDefinitions)
        {
            $fileName = ($Targets | Where-Object {$_.Name -eq $rule.Name}).Value.FullName

            if (Test-Path -Path $fileName)
            {
                $contents = Get-Content -Path $fileName
                $exceptions = $contents | Select-String -Pattern "^\s+.*throw"
                foreach($exception in $exceptions)
                {
                    if ($exception -match "^.*throw\s+'(?<Insight>ID\w+)'.*$")
                    {
                        $insights += $Matches.Insight
                    }
                }
            }
        }
    }

    if ($insights.Count -gt 0)
    {
        $str.AppendLine("### Insight action descriptions") | Out-Null
        $str.AppendLine("| **#** | **Language** | **Name** | **Description** | ") | Out-Null
        $str.AppendLine("|:------|:---------|:-----|:------------|") | Out-Null

        $index = 1
        foreach($insight in ($insights | Sort-Object -Unique))
        {
            $str.AppendLine(("| IA{2} | {3} | {0} | {1} |" -f $insight, $global:InsightActions.$insight, $index++, $OriginalCulture)) | Out-Null
        }

        $str.ToString() | Write-Verbose
    }

    return $str.ToString()
}

function New-Markdown
{
    param
    (
        [Parameter(Mandatory=$true)]
        [String]
        $Scenario
    )

    $obj = New-Object -TypeName $Scenario -ArgumentList ([guid]::Empty)

    if (-not [string]::IsNullOrEmpty($obj))
    {
        $str = New-Object -TypeName System.Text.StringBuilder

        $str.AppendLine("# $($obj.Description)") | Out-Null
        $str.AppendLine("**Owner:** [Owner of this document]") | Out-Null
        $str.AppendLine() | Out-Null

        $str.AppendLine("# Description") | Out-Null
        $str.AppendLine() | Out-Null
        $str.AppendLine("**[TODO]**") | Out-Null
        $str.AppendLine() | Out-Null

        $str.AppendLine("[[_TOC_]]") | Out-Null
        $str.AppendLine() | Out-Null

        $str.AppendLine("# Execution flow") | Out-Null
        $str.AppendLine() | Out-Null

        $str.AppendLine((New-MermaidDefinition -Scenario $obj)) | Out-Null
        $str.AppendLine() | Out-Null

        $str.AppendLine((New-RuleSpecification -Scenario $obj)) | Out-Null
        $str.AppendLine() | Out-Null

        $str.AppendLine((New-MessagesDefinition)) | Out-Null
        $str.AppendLine() | Out-Null

        $str.AppendLine((New-ScenarioDescription -Scenario $obj)) | Out-Null
        $str.AppendLine() | Out-Null

        $str.AppendLine((New-ParameterDescription -Scenario $obj)) | Out-Null
        $str.AppendLine() | Out-Null

        $str.AppendLine((New-AnalyzerDescription -Scenario $obj)) | Out-Null
        $str.AppendLine() | Out-Null

        $str.AppendLine((New-RuleDescription -Scenario $obj)) | Out-Null
        $str.AppendLine() | Out-Null

        $str.AppendLine((New-InsightDetectionDescription -Scenario $obj)) | Out-Null
        $str.AppendLine() | Out-Null

        $str.AppendLine((New-InsightActionDescription -Scenario $obj)) | Out-Null
        $str.AppendLine() | Out-Null

        $str.ToString() | Write-Verbose

        return $str.ToString()
    }
}

################
#####
################

$OriginalCulture  = ([System.Threading.Thread]::CurrentThread.CurrentCulture).Name

. (Join-Path -Path $Source -ChildPath common\Globals.ps1)
. (Join-Path -Path $Source -ChildPath common\Utils.ps1)

Initialize-ResourceString -Root $Source -MyMode $Product

Get-ChildItem -Path (Join-Path -Path $Source -ChildPath classes) -Recurse -File | ForEach-Object {. $_.FullName}

# Load product specific libraries
. (Join-Path -Path $Source -ChildPath mode\$Product\common\$Product.ps1)
. (Join-Path -Path $Source -ChildPath mode\$Product\common\Globals.ps1)

$Rules      = Get-ChildItem -Path "$Source\mode\$Product\rules"     -Recurse -Filter RD*.ps1 -File
$Insights   = Get-ChildItem -Path "$Source\mode\$Product\insights"  -Recurse -Filter ID*.ps1 -File
$Analyzers  = Get-ChildItem -Path "$Source\mode\$Product\analyzers" -Recurse -Filter AD*.ps1 -File
$Scenarios  = Get-ChildItem -Path "$Source\mode\$Product\scenarios" -Recurse -Filter SD*.ps1 -File
$Parameters = Get-ChildItem -Path "$Source\mode\$Product\parameters" -Recurse -Filter PD*.ps1 -File

$Targets = @()

foreach ($group in $Parameters, $Insights, $Rules, $Analyzers, $Scenarios)
{
    foreach ($file in $group)
    {
        "Sourcing $($file.FullName)..." | Write-Verbose
        . $file.FullName

        $target = New-Object PSObject
        Add-Member -InputObject $target -MemberType NoteProperty -Name "Name" -Value $file.BaseName
        Add-Member -InputObject $target -MemberType NoteProperty -Name "Value" -Value $file
        $Targets += $target
    }
}

# Create output folder, if it doesn't already exist
if (!(Test-Path -Path $Output))
{
    Write-Verbose("Creating output folder: $($Output)")
    New-Item -ItemType Directory -Path $Output
}

foreach($scenario in ($Scenarios.BaseName | Sort-Object))
{
    $markdown = New-Markdown -Scenario $scenario

    if(-not [string]::IsNullOrEmpty($markdown))
    {
        $OutputFile = Join-Path -Path $Output -ChildPath "$($scenario).md"

        $markdown | Out-File -FilePath $OutputFile -Encoding ascii -Force
        Write-Verbose("Generated file $($OutputFile)")
    }
}
