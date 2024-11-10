Import-Module -Name Microsoft.PowerShell.Management, Microsoft.PowerShell.Security, Microsoft.PowerShell.Utility, NetApp.ONTAP, Terminal-Icons -Verbose:$false
oh-my-posh init pwsh --config "$( ([System.IO.FileInfo]$PROFILE).directory.FullName )/amro.omp.json" | Invoke-Expression

try
{
    Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue
}
catch {}

$options = Get-PSReadLineOption
$options.EditMode = 'VI'
$options.ParameterColor = $PSStyle.Foreground.FromRGB('#8DEECC')
$options.VariableColor = $PSStyle.Foreground.FromRGB('#39CDF5')

Set-PSReadLineKeyHandler -Key Tab -Function Complete

. "$( ([System.IO.FileInfo]$PROFILE).Directory.FullName )/aliases.ps1"
. "$( ([System.IO.FileInfo]$PROFILE).Directory.FullName )/argument_completers.ps1"
. "$( ([System.IO.FileInfo]$PROFILE).Directory.FullName )/defaultParameters.ps1"
. "$( ([System.IO.FileInfo]$PROFILE).Directory.FullName )/general.ps1"
. "$( ([System.IO.FileInfo]$PROFILE).Directory.FullName )/bitwarden.ps1"

if ($psEditor.Workspace.Path)
{
    # in VS Code, start in the workspace!
    Set-Location ([Uri]$psEditor.Workspace.Path).AbsolutePath
}
elseif ( -not $IsMacOS )
{
    Set-Location ~\git
}


if ( Get-Variable IsMacOS -ErrorAction SilentlyContinue -ValueOnly )
{
    $(/opt/homebrew/bin/brew shellenv) | Invoke-Expression
}
