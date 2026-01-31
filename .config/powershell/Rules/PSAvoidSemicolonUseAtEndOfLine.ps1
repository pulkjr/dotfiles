<#
.SYNOPSIS
    The use of semicolons (;) and the end of lines is not required in PowerShell.
.DESCRIPTION
    Remove semicolons (;) from the end of lines.
.INPUTS
    [System.Management.Automation.Language.ScriptBlockAst]
.OUTPUTS
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
function PSAvoidSemicolonUseAtEndOfLine
{
    [CmdletBinding()]
    [OutputType( [System.Object] ) ]
    [OutputType( [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord] ) ]
    param
    (
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )

    begin
    {
        Set-StrictMode -Version 2.0
    }

    process
    {
        try
        {
            if ( [string]::IsNullOrWhiteSpace( $ScriptBlockAst.Parent ) -eq $false )
            {
                return
            }
            $tokens = $null
            $errors = $null
            $null = [System.Management.Automation.Language.Parser]::ParseInput( $ScriptBlockAst.ToString(), [ref]$tokens, [ref]$errors )

            [System.Management.Automation.Language.Token[]]$semiTokens = $tokens | Where-Object -Property Kind -EQ -Value 'Semi'

            foreach ( $token in $semiTokens )
            {
                if ( ( $ScriptBlockAst.ToString() -Split "`r`n" )[( $token.Extent.StartLineNumber - 1 )] -match ';$' )
                {
                    $correctionExtent = New-Object 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent' @(
                        [int]$token.Extent.StartLineNumber,
                        [int]$token.Extent.EndLineNumber,
                        [int]$token.Extent.StartColumnNumber,
                        [int]$token.Extent.EndColumnNumber,
                        [string]''
                        [string]$token.Extent.File,
                        [string]( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                    )

                    $suggestedCorrections = New-Object System.Collections.ObjectModel.Collection['Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent']
                    $suggestedCorrections.add( $correctionExtent ) | Out-Null

                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        Message              = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                        Extent               = $token.Extent
                        RuleName             = $MyInvocation.InvocationName
                        Severity             = 'Warning'
                        SuggestedCorrections = $suggestedCorrections
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
