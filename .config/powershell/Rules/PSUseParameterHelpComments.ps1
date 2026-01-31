<#
.SYNOPSIS
    Help comments for parameters should be above the parameter definition in the param block.
.DESCRIPTION
    Help comments for parameters should be above the parameter definition in the param block.
.INPUTS
    [System.Management.Automation.Language.ScriptBlockAst]
.OUTPUTS
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
function PSUseParameterHelpComments
{
    [CmdletBinding()]
    [OutputType( [System.Object] )]
    [OutputType( [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord] )]
    param
    (
        # Specifies the ScriptBlockAst to analyze
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
        if ( $null -eq $ScriptBlockAst.Parent )
        {
            $parameterList = $ScriptBlockAst.FindAll( { $args[0] -is [System.Management.Automation.Language.ParameterAst] }, $true )

            foreach ( $parameter in $parameterList )
            {
                if ( ( $ScriptBlockAst.Extent.Text -split '\n' )[ ( $parameter[0].Extent.StartLineNumber ) - 2 ].trim() -notmatch '^#' )
                {
                    $firstLine = ( $parameter.Extent.Text -split '\n' )[0]
                    $padding = $firstLine.Length + $parameter.Extent.StartColumnNumber - 1
                    $replaceText = ( $parameter.Extent.Text ).Replace( $firstLine, $firstLine.PadLeft( $padding, ' ' ) )

                    $correctionExtent = New-Object 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent' @(
                        [int]$parameter.Extent.StartLineNumber,
                        [int]$parameter.Extent.EndLineNumber,
                        [int]$parameter.Extent.StartColumnNumber,
                        [int]$parameter.Extent.EndColumnNumber,
                        [string]( "# Brief description of parameter`r`n" + $replaceText ),
                        [string]$parameter.Extent.File,
                        [string]'Add Help comment above parameter definition.'
                    )

                    $suggestedCorrections = New-Object System.Collections.ObjectModel.Collection['Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent']
                    $suggestedCorrections.Add( $correctionExtent ) | Out-Null

                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        Message              = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                        Extent               = $parameter.Extent
                        RuleName             = $MyInvocation.InvocationName
                        Severity             = 'Warning'
                        SuggestedCorrections = $suggestedCorrections
                    }
                }
            }
        }
    }
}

if ( $MyInvocation.ScriptName -match '.psm1$' )
{
    Export-ModuleMember -Function $( Split-Path -Path $PSCommandPath -Leaf ).Replace( '.ps1', '' )
}
