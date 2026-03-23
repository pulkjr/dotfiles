<#
.Synopsis
    Avoid using Out-Host.
.Description
    Out-Host should not be present in production code.
.Example
    PSAvoidUsingOutHost -CommandAst $CommandAst
.Inputs
    [System.Management.Automation.Language.CommandAst]
.Outputs
    [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
function PSAvoidUsingOutHost
{
    [CmdletBinding()]
    [OutputType( [System.Object] )]
    [OutputType( [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord] )]
    param
    (
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.CommandAst]
        $CommandAst
    )

    begin
    {
        Set-StrictMode -Version 2.0
    }

    process
    {
        try
        {
            $commandName = $CommandAst.GetCommandName()

            if ( $commandName -eq 'Out-Host' -or ( Get-Alias -Definition 'Out-Host' -ErrorAction SilentlyContinue ).Name -eq $commandName )
            {
                [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                    Message  = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                    Extent   = $CommandAst.Extent
                    RuleName = $MyInvocation.InvocationName
                    Severity = 'Warning'
                }
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError( $PSItem )
        }
    }
}

if ( $MyInvocation.ScriptName -match '.psm1$' )
{
    Export-ModuleMember -Function $( Split-Path -Path $PSCommandPath -Leaf ).Replace( '.ps1', '' )
}
