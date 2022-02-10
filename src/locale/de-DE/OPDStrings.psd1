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
# Created On: 3/1/2021 12:31 PM
#
# Last Modified On: 3/1/2021 12:31 PM
#################################################################################
#culture = "de-DE"
ConvertFrom-StringData @'
###PSLOC
	Accept                      = Akzeptieren
	AcceptEULA                  = Akzeptieren Sie die EULA
	Action                      = Aktion: {0}
	Area                        = Bereich
	BackALevel                  = z - Zurück zu {0}
	BackKey                     = z
	Choice                      = Wahl {0}
	ChooseOne                   = Sie müssen aus den folgenden:-ScenarioId,-ScenarioName,-Playlist oder keiner wählen (Standard)
	Continue                    = Fortsetzen
	Decline                     = Ablehnen
	Detection                   = Nachweis: {0}
	DoNotAcceptEULA             = Akzeptieren Sie die EULA nicht
	DoNotShareDataWithMicrosoft = Analyseergebnisse nicht mit Microsoft teilen
	Ending                      = Ende
	EnterToContinue             = Geben Sie weiter
	EULAAccepted                = EULA akzeptiert: Version {0} am {1}
	EULANotAccepted             = EULA wurde abgelehnt
	ExecScenario                = Laufszenario
	ExecutionID                 = ExecutionId
	ExecutionMarker             = {0} Die Ausführung für {1}
	Exit                        = a - Ausfahrt
	ExitKey                     = a
	Failure                     = [-] {0}
	InvalidChoice               = Ungültige Wahl:  "{0} "
	InvalidPlaylist             = Ungültige Playlist ' {0} '. Bitte prüfen Sie die Syntax und versuchen Sie es noch einmal
	IssueDiagnosed              = Haben Ihnen diese Informationen bei der Diagnose des Problems geholfen?
	KeepCurrentOPD              = Behalten Sie die aktuell installierte Version von OPD
	KeyValuePair                = {0} - {1}
	LoadingFiles                = Diagnose wird geladen ...
	MessageCritical             = KRITISCHE
	MessageError                = FEHLER
	MessageInfo                 = INFORMATIONEN
	MessageWarning              = WARNUNG
	MinPlaylist                 = Keine Szenarien, die in der Playlist ' {0} ' gefunden werden. Es muss mindestens ein Szenarion in der Playlist
	MinVersionOfPowershell      = OPD erfordert mindestens die Version {0} von PowerShell. Sie verwenden derzeit Version {1}. Anweisungen zum Installieren der erforderlichen PowerShell-Version finden Sie unter https://go.microsoft.com/fwlink/?linkid=839460.
	MissingResourceFile         = Ressourcendatei für {0} kann nicht geladen werden oder fehlt
	No                          = Nein
	OptIn                       = Ergebnisse der Aktienanalyse mit Microsoft
	Option                      = Möglichkeit
	OptOut                      = Analyseergebnisse nicht mit Microsoft teilen
	PercentComplete             = {0}% abgeschlossen:
	PlayListNotFound            = Playlist ' {0} ' existiert nicht. Bitte überprüfen und noch einmal versuchen
	Ready                       = Bereit
	RuleFailed                  = [-] {0}
	RulePassed                  = [?] {0}
	RunningAnalyzers            = Analysatoren werden ausgeführt...
	RunningRules                = Regeln werden ausgeführt...
	Scenario                    = Szenario
	SelectFromList              = Bitte wählen Sie aus der obigen Liste
	ShareDataWithMicrosoft      = Ergebnisse der Aktienanalyse mit Microsoft
	ShareResults                = Wären Sie bereit, dies mit Microsoft zu teilen?
	Starting                    = Beginnend
	Success                     = [+] {0}
	TelemetryUploading          = Hochladen von Telemetriedaten
	UnableToLoadAI              = Application Insights-DLL kann nicht geladen werden
	UnableToWriteAI             = Schreiben in Application Insights-Protokoll nicht möglich
	UpgradeAvailable            = Es ist eine neuere Version '{0}' von {1} verfügbar. Möchten Sie es installieren?
	UpgradeOPD                  = Aktualisieren Sie auf die neueste Version von OPD
	Yes                         = Ja
###PSLOC
'@

