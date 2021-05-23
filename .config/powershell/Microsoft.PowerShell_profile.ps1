Import-Module -Name Microsoft.PowerShell.Management, Microsoft.PowerShell.Security, Microsoft.PowerShell.Utility -Verbose:$false

Import-Module oh-my-posh, Terminal-Icons
Set-PoshPrompt -Theme /Users/jpulk/.go-my-posh.json
Set-PSReadLineOption -Colors @{ Parameter = '#34b7eb' }

. "$( ([System.IO.FileInfo]$PROFILE).directory.FullName )/aliases.ps1"
. "$( ([System.IO.FileInfo]$PROFILE).directory.FullName )/argument_completers.ps1"
. "$( ([System.IO.FileInfo]$PROFILE).directory.FullName )/defaultParameters.ps1"
. "$( ([System.IO.FileInfo]$PROFILE).directory.FullName )/general.ps1"

if ($psEditor.Workspace.Path) { # in VS Code, start in the workspace!
    Set-Location ([Uri]$psEditor.Workspace.Path).AbsolutePath
} else {
    Set-Location ~\git
}