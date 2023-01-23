Import-Module -Name Microsoft.PowerShell.Management, Microsoft.PowerShell.Security, Microsoft.PowerShell.Utility, SecretManagement.LastPass, netapp.ontap -Verbose:$false
oh-my-posh init pwsh --config "$( ([System.IO.FileInfo]$PROFILE).directory.FullName )/atomicBit.omp.json" | Invoke-Expression
Import-Module Terminal-Icons
try
{
    Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue
}
catch {}

$options = Get-PSReadLineOption
$options.ParameterColor = $PSStyle.Foreground.FromRGB('#8DEECC')
$options.VariableColor = $PSStyle.Foreground.FromRGB('#39CDF5')

Set-PSReadLineKeyHandler -Key Tab -Function Complete

. "$( ([System.IO.FileInfo]$PROFILE).directory.FullName )/aliases.ps1"
. "$( ([System.IO.FileInfo]$PROFILE).directory.FullName )/argument_completers.ps1"
. "$( ([System.IO.FileInfo]$PROFILE).directory.FullName )/defaultParameters.ps1"
. "$( ([System.IO.FileInfo]$PROFILE).directory.FullName )/general.ps1"

if ($psEditor.Workspace.Path)
{
    # in VS Code, start in the workspace!
    Set-Location ([Uri]$psEditor.Workspace.Path).AbsolutePath
}
elseif ( -not $IsMacOS )
{
    Set-Location ~\git
}

$jiraApiKey = ''
$confluenceCred = [PSCredential]::new('joseph.pulk@netapp.com', ( ConvertTo-SecureString -String '' -AsPlainText ))
$jira = @{
    link     = 'https://jira01.development.smit-th.com/'
    username = 'joseph.pulk@netapp.com'
    key      = ConvertTo-SecureString $jiraApiKey -AsPlainText -Force
}
$jiraCred = [pscredential]::new( $jira.UserName, $jira.key )

$jiraHeaders = @{
    Authorization = "Bearer $jiraApiKey"
}
Set-JiraConfigServer -Server $jira.link


$HTTP_Request = [System.Net.WebRequest]::Create($jira.link)
$HTTP_Response = $HTTP_Request.GetResponse()
$HTTP_Status = [int]$HTTP_Response.StatusCode

If ($HTTP_Status -eq 200)
{
    New-JiraSession -Credential $jiraCred -Headers $jiraHeaders | Out-Null
}
# Set-ConfluenceInfo -Credential $confluenceCred -BaseURI 'https://confluence01.development.smit-th.com/'