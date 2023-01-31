Import-Module -Name Microsoft.PowerShell.Management, Microsoft.PowerShell.Security, Microsoft.PowerShell.Utility, NetApp.ONTAP, Terminal-Icons -Verbose:$false
oh-my-posh init pwsh --config "$( ([System.IO.FileInfo]$PROFILE).directory.FullName )/amro.omp.json" | Invoke-Expression

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

[string] $jiraApiKey = (bw get 'password' 'JiraApiKey')

if ( -not ([string]::IsNullOrEmpty( $jiraApiKey ) ) )
{
    Import-Module JiraPs
    $jiraUsername = (bw get "username" "JiraApiKey")
    $jira = @{
        link     = 'https://jira01.development.smit-th.com/'
        username = $jiraUsername
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
}
else
{
    Write-Host -ForegroundColor Red "Jira API Key not present"
}



[string] $confluenceApiKey = (bw get "password" "ConfluenceApiKey")
if ( -not ([string]::IsNullOrEmpty( $confluenceApiKey ) ) )
{
    Import-Module ConfluencePS
    $confluenceUserName = (bw get "password" "ConfluenceApiKey")
    $confluenceCred = [PSCredential]::new($confluenceUserName, ( ConvertTo-SecureString -String $confluenceApiKey -AsPlainText ))
    $HTTP_Request = [System.Net.WebRequest]::Create('https://confluence01.development.smit-th.com/')
    $HTTP_Response = $HTTP_Request.GetResponse()
    $HTTP_Status = [int]$HTTP_Response.StatusCode
    
    If ($HTTP_Status -eq 200)
    {
        New-JiraSession -Credential $jiraCred -Headers $jiraHeaders | Out-Null
    }
    Set-ConfluenceInfo -Credential $confluenceCred -BaseURI 'https://confluence01.development.smit-th.com/'
}
else
{
    Write-Host -ForegroundColor Red "Confluent API Key not present"
}

[string] $cmciUserName = (bw get "username" "cmci")
if ( -not ([string]::IsNullOrEmpty( $cmciUserName ) ) )
{
    [pscredential]$cmci = [PSCredential]::new($cmciUserName, ( ConvertTo-SecureString -String (bw get "password" "cmci") -AsPlainText ))
}
else
{
    Write-Host -ForegroundColor Red "CMCI username not present"
}