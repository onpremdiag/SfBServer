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
# Filename: CommonStrings.psd1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 3/1/2021 12:10 PM
#
# Last Modified On: 3/1/2021 12:10 PM
#################################################################################
#culture = "en-US"
ConvertFrom-StringData @'
###PSLOC
	AnalyzerCompleted = {0} completed. No issues detected
	AnalyzerFailure   = stopping. An issue has been detected with following Analyzer: {0}
	AnalyzerSuccess   = AFTER: ExecutionId: {0}, Description: {1}, Success: {2}
	CreatingScenario  = Creating scenario: {0}
	ExecutingAnalyzer = Executing Analyzer: {0}
	ExecutingRule     = {0} - {1} - {2} - {3}
	ExecutingScenario = Executing [{0}] - {1}
	InsightAction     = Action: {0}
	InsightDetection  = Detection: {0}
	InvalidProduct    = Invalid product '{0}' specified. Choose from the list: {1}
	RuleCompleted     = {0} - {1} - {2} - {3} Success = {4}
	RuleHasInsight    = *** INSIGHT FOUND ***
	RuleNoInsight     = No insight found for this failure: {0}
	ScenarioResult    = Result from [{0}] - {1} : {2}
###PSLOC
'@