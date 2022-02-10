@{
    Severity = @('Error', 'Warning')

    ExcludeRules = @(
        'PSAvoidGlobalVars',
        'PSAvoidInvokingEmptyMembers',
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingUserNameAndPassWordParams',
        'PSAvoidUsingWriteHost',
        'PSUseBOMForUnicodedFile',
        'PSUseBOMForUnicodeEncodedFile',
        'PSUseCmdletCorrectly',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSingularNouns',
        'PSUseSupportsShouldProcess'
    )

    IncludeRules = @(
        'PSAlignAssignmentStatement',
        'PSAvoidTrailingWhiteSpace',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingEmptyCatchBlock',
        'PSAvoidUsingPositionalParameters',
        'PSPlaceCloseBrace',
        'PSPlaceOpenBrace',
        'PSUseConsistentIndentation'
    )

    Rules = @{
        PSPlaceOpenBrace       = @{
            Enable             = $true
            OnSameLine         = $false
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace      = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }

        PSUseConsistentIndentation = @{
            Enable                 = $false
            Kind                   = 'space'
            IndentationSize        = 4
        }

        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $false
        }
    }
}