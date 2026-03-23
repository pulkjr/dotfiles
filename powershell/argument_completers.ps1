Register-ArgumentCompleter -CommandName Invoke-Build.ps1 -ParameterName Task -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $boundParameters)

    (& 'Invoke-Build' ?? -File ($boundParameters['File'])).Keys -like "$wordToComplete*" | . { process
        {
            New-Object System.Management.Automation.CompletionResult $_, $_, 'ParameterValue', $_
        } }
}

Register-ArgumentCompleter -CommandName Invoke-Build.ps1 -ParameterName File -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $boundParameters)

    Get-ChildItem -Directory -Name "$wordToComplete*" | . { process
        {
            New-Object System.Management.Automation.CompletionResult $_, $_, 'ProviderContainer', $_
        } }

    if (!($boundParameters['Task'] -eq '**'))
    {
        Get-ChildItem -File -Name "$wordToComplete*.ps1" | . { process
            {
                New-Object System.Management.Automation.CompletionResult $_, $_, 'Command', $_
            } }
    }
}