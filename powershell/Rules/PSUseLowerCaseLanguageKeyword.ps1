<#
.Synopsis
    Tests for the use of language keywords with only lowercase letters.
.Description
    For style consistency all PowerShell language keywords should be in all lower case.
.Inputs
    [System.Management.Automation.Language.ScriptBlockAst]
.Outputs
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
function PSUseLowerCaseLanguageKeyword
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
                if ( $tokenObj.TokenFlags.HasFlag( [System.Management.Automation.Language.TokenFlags]::Keyword ) -eq $true )
                {
                    $expectedText = [System.Management.Automation.Language.TokenTraits]::Text( $tokenObj.Kind )
                    if ( $tokenObj.Extent.Text -cne $expectedText )
                    {
                        $correctionExtent = New-Object 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent' @(
                            [int]$tokenObj.Extent.StartLineNumber,
                            [int]$tokenObj.Extent.EndLineNumber,
                            [int]$tokenObj.Extent.StartColumnNumber,
                            [int]$tokenObj.Extent.EndColumnNumber,
                            [string]$tokenObj.Extent.Text.ToLower(),
                            [string]$tokenObj.Extent.File,
                            [string]'Change language keyword to all lower case.'
                        )

                        $suggestedCorrections = New-Object System.Collections.ObjectModel.Collection['Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent']
                        $suggestedCorrections.Add( $correctionExtent ) | Out-Null

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
