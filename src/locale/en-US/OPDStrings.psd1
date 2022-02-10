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
# Filename: OPDStrings.psd1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 3/1/2021 12:11 PM
#
# Last Modified On: 3/1/2021 12:11 PM
#################################################################################
#culture = "en-US"
ConvertFrom-StringData @'
###PSLOC
	Accept                      = Accept
	AcceptEULA                  = Accept the EULA
	Action                      = Action : {0}
	Area                        = Area
	BackALevel                  = b - Back to {0}
	BackKey                     = b
	Choice                      = Choosing {0}
	ChooseOne                   = You must choose one from the following:-ScenarioId, -ScenarioName, -Playlist, or none (default)
	Continue                    = Continue
	Decline                     = Decline
	Detection                   = Detection : {0}
	DoNotAcceptEULA             = Do not accept the EULA
	DoNotShareDataWithMicrosoft = Do not share analysis results with Microsoft
	Ending                      = Ending
	EnterToContinue             = Enter to continue
	EULAAccepted                = EULA accepted: Version {0} on {1}
	EULANotAccepted             = EULA has been declined
	ExecScenario                = Running scenario
	ExecutionID                 = ExecutionId
	ExecutionMarker             = {0} execution for {1}
	Exit                        = x - eXit
	ExitKey                     = x
	Failure                     = [-] {0}
	InvalidChoice               = Invalid choice: "{0}"
	InvalidPlaylist             = Invalid playlist '{0}'. Please check the syntax and try again
	IssueDiagnosed              = Did this information help you diagnose the problem?
	KeepCurrentOPD              = Keep the currently installed version of OPD
	KeyValuePair                = {0} - {1}
	LoadingFiles                = Loading diagnostics...
	MessageCritical             = CRITICAL
	MessageError                = ERROR
	MessageInfo                 = INFORMATION
	MessageWarning              = WARNING
	MinPlaylist                 = No scenarios found in playlist '{0}'. There must be at least one scenarion in the playlist
	MinVersionOfPowershell      = OPD requires at least version {0} of PowerShell. You are currently running version {1}. Please refer to https://go.microsoft.com/fwlink/?linkid=839460 for instructions on how to install the required version of PowerShell.
	MissingResourceFile         = Unable to load or missing resource file for {0}
	No                          = No
	OptIn                       = Share analysis results with Microsoft
	Option                      = Option
	OptOut                      = Do not share analysis results with Microsoft
	PercentComplete             = {0}% Complete:
	PlayListNotFound            = Playlist '{0}' does not exist. Please verify and try again
	Ready                       = Ready
	RuleFailed                  = [-] {0}
	RulePassed                  = [?] {0}
	RunningAnalyzers            = Running analyzers...
	RunningRules                = Running rules...
	Scenario                    = Scenario
	SelectFromList              = Please select from the list above
	ShareDataWithMicrosoft      = Share analysis results with Microsoft
	ShareResults                = Would you be willing to share this with Microsoft?
	Starting                    = Starting
	Success                     = [+] {0}
	TelemetryUploading          = Uploading telemetry data
	UnableToLoadAI              = Unable to load Application Insights dll
	UnableToWriteAI             = Unable to write to application insights log
	UpgradeAvailable            = There is a newer version '{0}' of {1} available. Would you like to install it?
	UpgradeOPD                  = Upgrade to the most recent version of OPD
	Yes                         = Yes
###PSLOC
'@
