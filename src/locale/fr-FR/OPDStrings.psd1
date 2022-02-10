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
	BackALevel                  = r - retour � {0}
	BackKey                     = r
	Choice                      = Choix de {0}
	ChooseOne                   = Vous devez choisir un des �l�ments suivants:-ScenarioId,-ScenarioName,-playlist ou None (par d�faut)
	Continue                    = Continuer
	Decline                     = D�clin
	Detection                   = Detection : {0}
	DoNotAcceptEULA             = N'acceptez pas le EULA
	DoNotShareDataWithMicrosoft = Ne partagez pas les r�sultats d'analyse avec Microsoft
	Ending                      = Fin
	EnterToContinue             = Entrer pour continuer
	EULAAccepted                = CLUF accept�: version {0} sur {1}
	EULANotAccepted             = CLUF a �t� refus�
	ExecScenario                = Sc�nario de fonctionnement
	ExecutionID                 = ExecutionId
	ExecutionMarker             = {0} ex�cution pour {1}
	Exit                        = s - Sortie
	ExitKey                     = s
	Failure                     = [-] {0}
	InvalidChoice               = Choix non valide:  "{0} "
	InvalidPlaylist             = Liste de lecture non valide' {0} '. Veuillez v�rifier la syntaxe et r�essayer
	IssueDiagnosed              = Ces informations vous ont-elles aid� � diagnostiquer le probl�me?
	KeepCurrentOPD              = Conserver la version actuellement install�e de OPD
	KeyValuePair                = {0} - {1}
	LoadingFiles                = Chargement des diagnostics ...
	MessageCritical             = CRITIQUE
	MessageError                = ERREUR
	MessageInfo                 = INFORMATIONS
	MessageWarning              = AVERTISSEMENT
	MinPlaylist                 = Aucun sc�nario n'a �t� trouv� dans la playlist' {0} '. Il doit y avoir au moins un sc�nario dans la playlist
	MinVersionOfPowershell      = OPD requiert au moins la version {0} de PowerShell. Vous utilisez actuellement la version {1}. Veuillez consulter https://go.microsoft.com/fwlink/?linkid=839460 pour obtenir des instructions sur l'installation de la version requise de PowerShell.
	MissingResourceFile         = Impossible de charger ou fichier de ressource manquant pour {0}
	No                          = Pas
	OptIn                       = Partager les r�sultats d'analyse avec Microsoft
	Option                      = Option
	OptOut                      = Ne partagez pas les r�sultats d'analyse avec Microsoft
	PercentComplete             = {0}% termin�:
	PlayListNotFound            = La playlist' {0} 'n'existe pas. Veuillez v�rifier et r�essayer
	Ready                       = Pr�t
	RuleFailed                  = [-] {0}
	RulePassed                  = [?] {0}
	RunningAnalyzers            = Ex�cution d�analyseurs...
	RunningRules                = R�gles d�ex�cution...
	Scenario                    = Sc�nario
	SelectFromList              = Veuillez s�lectionner dans la liste ci-dessus
	ShareDataWithMicrosoft      = Partager les r�sultats d'analyse avec Microsoft
	ShareResults                = Seriez-vous pr�t � partager cela avec Microsoft?
	Starting                    = Commencer
	Success                     = [+] {0}
	TelemetryUploading          = T�l�chargement de donn�es de t�l�m�trie
	UnableToLoadAI              = Impossible de charger la DLL d'application Insights
	UnableToWriteAI             = Impossible d'�crire dans le journal Insights de l'application
	UpgradeAvailable            = Une version plus r�cente '{0}' de {1} est disponible. Voulez-vous l'installer?
	UpgradeOPD                  = Mise � niveau vers la version la plus r�cente de OPD
	Yes                         = Oui
###PSLOC
'@
