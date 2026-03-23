@{
    IncludeDefaultRules = $true
    Severity            = @('Error', 'Warning', 'Information')
    ExcludeRules        = @(
        'PSAvoidUsingWMICmdlet'
        'PSUseDeclaredVarsMoreThanAssignments'
        'PSUseOutputType'
        'PSUseCmdletBinding'
        'PSUseSetStrictMode'
    )
    Rules               = @{
        PSAvoidUsingCmdletAliases   = @{
            Whitelist = @( 'task' )
        }
        PSPlaceOpenBrace            = @{
            Enable             = $true
            OnSameLine         = $false
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }
        PSPlaceCloseBrace           = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $true
        }
        PSUseConsistentIndentation  = @{
            Enable              = $true
            Kind                = 'space'
            IndentationSize     = 4
            PipelineIndentation = 'NoIndentation'
        }
        PSUseConsistentWhitespace   = @{
            Enable         = $true
            CheckOpenBrace = $false
            CheckOperator  = $false
        }
        PSAlignAssignmentStatement  = @{
            Enable         = $true
            CheckHashtable = $true
        }
        PSProvideCommentHelp        = @{
            Enable       = $false
            ExportedOnly = $false
        }
        PSUseCorrectCasing          = @{
            Enable = $true
        }
        PSUsePSItemPipelineVariable = @{
            Enable = $true
        }
    }
}
