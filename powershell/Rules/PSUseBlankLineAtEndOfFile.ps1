<#
.SYNOPSIS
     It is a best practice to end files with a blank line and some utilities require it.
.DESCRIPTION
    Add a blank line to the end of the file.
.INPUTS
    [System.Management.Automation.Language.ScriptBlockAst]
.OUTPUTS
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]
#>
function PSUseBlankLineAtEndOfFile
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
            if ( [string]::IsNullOrWhiteSpace( $ScriptBlockAst.Parent ) -eq $true )
            {
                if ( ( $ScriptBlockAst.Extent.Text -split '\n' )[-1].Length -ne 0 )
                {
                    $correctionExtent = New-Object 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent' @(
                        [int]$ScriptBlockAst.Extent.StartLineNumber,
                        [int]$ScriptBlockAst.Extent.EndLineNumber,
                        [int]$ScriptBlockAst.Extent.StartColumnNumber,
                        [int]$ScriptBlockAst.Extent.EndColumnNumber,
                        [string]( $ScriptBlockAst.Extent.ToString() + "`n" ),
                        [string]$ScriptBlockAst.Extent.File,
                        [string]'Add a blank line to the end of the file.'
                    )

                    $suggestedCorrections = New-Object System.Collections.ObjectModel.Collection['Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent']
                    $suggestedCorrections.add( $correctionExtent ) | Out-Null

                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        Message              = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                        Extent               = $ScriptBlockAst.Extent
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
