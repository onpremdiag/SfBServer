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
# Created On: 3/1/2021 12:22 PM
#
# Last Modified On: 3/1/2021 12:22 PM
#################################################################################
#culture = "fr-FR"
ConvertFrom-StringData @'
###PSLOC
	Accept                      = Acceptez
	AcceptEULA                  = Accepter le EULA
	Action                      = Action : {0}
	Area                        = Zone
	BackALevel                  = r - retour à {0}
	BackKey                     = r
	Choice                      = Choix de {0}
	ChooseOne                   = Vous devez choisir un des éléments suivants:-ScenarioId,-ScenarioName,-playlist ou None (par défaut)
	Continue                    = Continuer
	Decline                     = Déclin
	Detection                   = Detection : {0}
	DoNotAcceptEULA             = N'acceptez pas le EULA
	DoNotShareDataWithMicrosoft = Ne partagez pas les résultats d'analyse avec Microsoft
	Ending                      = Fin
	EnterToContinue             = Entrer pour continuer
	EULAAccepted                = CLUF accepté: version {0} sur {1}
	EULANotAccepted             = CLUF a été refusé
	ExecScenario                = Scénario de fonctionnement
	ExecutionID                 = ExecutionId
	ExecutionMarker             = {0} exécution pour {1}
	Exit                        = s - Sortie
	ExitKey                     = s
	Failure                     = [-] {0}
	InvalidChoice               = Choix non valide:  "{0} "
	InvalidPlaylist             = Liste de lecture non valide' {0} '. Veuillez vérifier la syntaxe et réessayer
	IssueDiagnosed              = Ces informations vous ont-elles aidé à diagnostiquer le problème?
	KeepCurrentOPD              = Conserver la version actuellement installée de OPD
	KeyValuePair                = {0} - {1}
	LoadingFiles                = Chargement des diagnostics ...
	MessageCritical             = CRITIQUE
	MessageError                = ERREUR
	MessageInfo                 = INFORMATIONS
	MessageWarning              = AVERTISSEMENT
	MinPlaylist                 = Aucun scénario n'a été trouvé dans la playlist' {0} '. Il doit y avoir au moins un scénario dans la playlist
	MinVersionOfPowershell      = OPD requiert au moins la version {0} de PowerShell. Vous utilisez actuellement la version {1}. Veuillez consulter https://go.microsoft.com/fwlink/?linkid=839460 pour obtenir des instructions sur l'installation de la version requise de PowerShell.
	MissingResourceFile         = Impossible de charger ou fichier de ressource manquant pour {0}
	No                          = Pas
	OptIn                       = Partager les résultats d'analyse avec Microsoft
	Option                      = Option
	OptOut                      = Ne partagez pas les résultats d'analyse avec Microsoft
	PercentComplete             = {0}% terminé:
	PlayListNotFound            = La playlist' {0} 'n'existe pas. Veuillez vérifier et réessayer
	Ready                       = Prêt
	RuleFailed                  = [-] {0}
	RulePassed                  = [?] {0}
	RunningAnalyzers            = Exécution d’analyseurs...
	RunningRules                = Règles d’exécution...
	Scenario                    = Scénario
	SelectFromList              = Veuillez sélectionner dans la liste ci-dessus
	ShareDataWithMicrosoft      = Partager les résultats d'analyse avec Microsoft
	ShareResults                = Seriez-vous prêt à partager cela avec Microsoft?
	Starting                    = Commencer
	Success                     = [+] {0}
	TelemetryUploading          = Téléchargement de données de télémétrie
	UnableToLoadAI              = Impossible de charger la DLL d'application Insights
	UnableToWriteAI             = Impossible d'écrire dans le journal Insights de l'application
	UpgradeAvailable            = Une version plus récente '{0}' de {1} est disponible. Voulez-vous l'installer?
	UpgradeOPD                  = Mise à niveau vers la version la plus récente de OPD
	Yes                         = Oui
###PSLOC
'@
