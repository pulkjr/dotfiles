@{
    IncludeDefaultRules = $true
    Severity            = @('Error', 'Warning', 'Information')
    ExcludeRules        = @('PSAvoidUsingWMICmdlet')
    Rules               = @{
        PSAvoidUsingCmdletAliases  = @{
            Whitelist = @( 'task' )
        }
        PSPlaceOpenBrace           = @{
            Enable             = $true
            OnSameLine         = $false
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }
        PSPlaceCloseBrace          = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $true
        }
        PSUseConsistentIndentation = @{
            Enable              = $true
            Kind                = 'space'
            IndentationSize     = 4
            PipelineIndentation = 'NoIndentation'
        }
        PSUseConsistentWhitespace  = @{
            Enable         = $true
            CheckOpenBrace = $false
            CheckOperator  = $false
        }
        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $true
        }
        PSProvideCommentHelp       = @{
            Enable       = $true
            ExportedOnly = $false
        }
        PSUseCorrectCasing         = @{
            Enable = $true
        }
    }
}
