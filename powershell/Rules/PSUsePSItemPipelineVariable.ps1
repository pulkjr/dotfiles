<#
.SYNOPSIS
    Tests for the use of the $_ automatic pipeline variable instead of $PSItem.
.DESCRIPTION
    Use $_ instead for increased consistency. Unless you are specifically supporting PowerShell v2 where $PSItem is not supported.
.INPUTS
    [System.Management.Automation.Language.ScriptBlockAst]
.OUTPUTS
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
function PSUsePSItemPipelineVariable
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
            foreach ( $tokenObj in $Token | Where-Object -Property Kind -EQ -Value 'Variable' )
            {
                if ( $tokenObj.Name -eq 'PSItem' )
                {
                    $correctionExtent = New-Object 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent'@(
                        [int]$tokenObj.Extent.StartLineNumber,
                        [int]$tokenObj.Extent.EndLineNumber,
                        [int]$tokenObj.Extent.StartColumnNumber,
                        [int]$tokenObj.Extent.EndColumnNumber,
                        [string]'$_',
                        [string]$tokenObj.Extent.File,
                        [string]'Replace all instances of $PSItem with $_'
                    )

                    $suggestedCorrections = New-Object System.Collections.ObjectModel.Collection['Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent']
                    $suggestedCorrections.add( $correctionExtent ) | Out-Null

                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        Message              = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                        Extent               = $tokenObj.Extent
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
