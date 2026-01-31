<#
.SYNOPSIS
    Tests for the use of the backticks ( ` ) for line continuation.
.DESCRIPTION
    Do not use backticks ( ` ) for line continuation.  Use splatting instead to increase readability.
.INPUTS
    [System.Management.Automation.Language.ScriptBlockAst]
.OUTPUTS
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
function PSAvoidUsingBacktick
{
    [CmdletBinding()]
    [OutputType( [System.Object] ) ]
    [OutputType( [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord] ) ]
    param
    (
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.Token[]]
        $Token
    )

    begin
    {
        Set-StrictMode -Version 2.0
    }

    process
    {
        try
        {
            foreach ( $tokenObj in $Token )
            {
                if ( $tokenObj.Kind -eq [System.Management.Automation.Language.TokenKind]::LineContinuation )
                {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        Message  = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                        Extent   = $tokenObj.Extent
                        RuleName = $MyInvocation.InvocationName
                        Severity = 'Warning'
                    }
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
