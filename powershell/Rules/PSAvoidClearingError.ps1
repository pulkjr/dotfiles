<#
.Synopsis
    Clearing the automatic error variable ( $Error ) can make troubleshooting issues difficult.
.Description
    Do not clear the $Error automatic variable.
.Inputs
    [System.Management.Automation.Language.ScriptBlockAst]
.Outputs
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
function PSAvoidClearingError
{
    [CmdletBinding()]
    [OutputType( [System.Object] ) ]
    [OutputType( [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord] ) ]
    param
    (
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.InvokeMemberExpressionAst]
        $InvokeMemberExpressionAst
    )

    begin
    {
        Set-StrictMode -Version 2.0
    }

    process
    {
        if ( $InvokeMemberExpressionAst.Expression.ToString() -eq '$error' -and $InvokeMemberExpressionAst.Member.ToString() -eq 'Clear' )
        {
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                Message  = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                Extent   = $InvokeMemberExpressionAst.Extent
                RuleName = $MyInvocation.InvocationName
                Severity = 'Warning'
            }
        }
    }
}

if ( $MyInvocation.ScriptName -match '.psm1$' )
{
    Export-ModuleMember -Function $( Split-Path -Path $PSCommandPath -Leaf ).Replace( '.ps1', '' )
}
