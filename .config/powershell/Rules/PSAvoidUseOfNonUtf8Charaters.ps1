<#
.SYNOPSIS
    Tests for non-printable ASCII characters.
.DESCRIPTION
    Remove all non-printable ASCII characters. These characters can prevent the commands from executing.
.INPUTS
    [System.Management.Automation.Language.ScriptBlockAst]
.OUTPUTS
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
function PSAvoidUseOfNonUtf8Charaters
{
    [CmdletBinding()]
    [OutputType( [System.Object[]] ) ]
    [OutputType( [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord] ) ]
    param
    (
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst[]]
        $Ast
    )

    begin
    {
        Set-StrictMode -Version 2.0
    }

    process
    {
        try
        {
            [regex]$charPattern = [regex]::new( '[\x80-\xFE]+' )

            if ( $ast.Extent.Text -match $charPattern -and [string]::IsNullOrWhiteSpace( ( $ast.Parent ) ) -eq $true )
            {
                $correctionExtent = New-Object 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent' @(
                    [int]$ast.Extent.StartLineNumber,
                    [int]$ast.Extent.EndLineNumber,
                    [int]$ast.Extent.StartColumnNumber,
                    [int]$ast.Extent.EndColumnNumber,
                    [string]"$( [regex]::Replace( $ast.Extent.Text, $charPattern, ' ' ) )",
                    [string]$ast.Extent.File,
                    [string]'Remove any non-printable characters.'
                )

                $suggestedCorrections = New-Object System.Collections.ObjectModel.Collection['Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent']
                $suggestedCorrections.add( $correctionExtent ) | Out-Null

                [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                    Message              = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                    Extent               = $ast.Extent
                    RuleName             = $MyInvocation.InvocationName
                    Severity             = 'Warning'
                    SuggestedCorrections = $suggestedCorrections
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
