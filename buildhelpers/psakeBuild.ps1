Include "$PSScriptRoot\build_utils.ps1"

task default -depends Analyze, Test

task Analyze -depends AnalyzeClasses, AnalyzeCommon, AnalyzeConsole, AnalyzeProduct {}

task AnalyzeClasses {
    $saResults = Invoke-ScriptAnalyzer -Path $SourceDirectory\src\classes `
        -Profile "$SourceDirectory\buildhelpers\PSScriptAnalyzerSettings.psd1" `
        -Recurse | Where-Object {$_.RuleName -ne 'TypeNotFound'}

    if ($saResults) {
        $saResults | Sort-Object -Property @{Expression="ScriptName"}, @{Expression="Severity"}, @{Expression="RuleName"} | Format-Table
        Write-Error -Message "One or more Script Analyzer erros/warnding were found. Build cannot continue"
    }
}

task AnalyzeCommon {
    $saResults = Invoke-ScriptAnalyzer -Path $SourceDirectory\src\common `
        -Profile "$SourceDirectory\buildhelpers\PSScriptAnalyzerSettings.psd1" `
        -Recurse | Where-Object {$_.RuleName -ne 'TypeNotFound'}

    if ($saResults) {
        $saResults | Format-Table
        Write-Error -Message "One or more Script Analyzer erros/warnding were found. Build cannot continue"
    }
}

task AnalyzeConsole {
    $saResults = Invoke-ScriptAnalyzer -Path $SourceDirectory\src\OPD-console.ps1 `
        -Profile "$SourceDirectory\buildhelpers\PSScriptAnalyzerSettings.psd1" `
        -Recurse | Where-Object {$_.RuleName -ne 'TypeNotFound'}

    if ($saResults) {
        $saResults | Format-Table
        Write-Error -Message "One or more Script Analyzer erros/warnding were found. Build cannot continue"
    }
}

task AnalyzeProduct {
    $saResults = Invoke-ScriptAnalyzer -Path $SourceDirectory\src\mode\$Product `
        -Profile "$SourceDirectory\buildhelpers\PSScriptAnalyzerSettings.psd1" `
        -Recurse | Where-Object {$_.RuleName -ne 'TypeNotFound'}

    if ($saResults) {
        $saResults | Format-Table
        Write-Error -Message "One or more Script Analyzer erros/warnding were found. Build cannot continue"
    }
}

task Test -depends Test-English {}

task Test-Core {

}

task Test-English {
    $testResults = Using-Culture -Culture 'en-US' `
        -ScriptBlock {
            Invoke-Pester $sourceDirectory\OnPremDiagTests `
            -Tag 'Core', $Product `
            -OutputFile $sourceDirectory\Test-Pester.en-US.xml `
            -OutputFormat NUnitXml `
            -PassThru `
            -Show None
        }

    # Show all passing tests
    $testResults.TestResult | Where-Object {$_.Result -eq 'Passed'} `
        | Sort-Object -Property Describe, Name `
        | Format-Table -Property Describe, Name, Result
    Write-Host "Successful Pester tests" -ForegroundColor Green -BackgroundColor Black

    # Do we have any pending/inconclusive test results? If so, let's show them and issue a warning
    if ($testResults.PendingCount -gt -0)
    {
        $testResults.TestResult | Where-Object {$_.Result -eq 'Pending'} `
            | Sort-Object -Property Describe, Name `
            | Format-Table -Property Describe, Name, Result
        Write-Host "Inconclusive Pester tests. Please modify and re-submit" `
            -ForegroundColor Yellow -BackgroundColor Black
    }

    # If we have any failures, let's show them
    if ($testResults.FailedCount -gt 0)
    {
        $testResults.TestResult | Where-Object {$_.Result -eq 'Failed'} `
            | Sort-Object -Property Describe, Name `
            | Format-Table -Wrap -Property Describe, Name, FailureMessage, StackTrace

        Write-Host "Failing Pester tests" -ForegroundColor Red -BackgroundColor Black
    }
}