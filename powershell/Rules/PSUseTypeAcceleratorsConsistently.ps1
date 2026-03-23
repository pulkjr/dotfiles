<#
.Synopsis
    Use type accelerators.
.Description
    Type accelerators should be used when possible.
.Example
    PSUseTypeAcceleratorsConsistently -TypeConstraintAst $TypeConstraintAst
.Inputs
    [System.Management.Automation.Language.TypeConstraintAst]
.Outputs
    [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord
#>
function PSUseTypeAcceleratorsConsistently
{
    [CmdletBinding()]
    [OutputType( [System.Object] )]
    [OutputType( [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord] )]
    param
    (
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.TypeConstraintAst]
        $TypeConstraintAst
    )

    begin
    {
        Set-StrictMode -Version 2.0
        # This returns the host's PowerShell version specific acclerators
        $accelerators = [hashtable][psobject].Assembly.GetType( 'System.Management.Automation.TypeAccelerators' )::Get
    }
    process
    {
        try
        {
            $typeName = $TypeConstraintAst.TypeName.ToString() -replace '\[\]'

            if ( $accelerators.Values.FullName -contains $typeName )
            {
                $correctionExtent = New-Object 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent' @(
                    [int]$TypeConstraintAst.Extent.StartLineNumber
                    [int]$TypeConstraintAst.Extent.EndLineNumber
                    [int]$TypeConstraintAst.Extent.StartColumnNumber
                    [int]$TypeConstraintAst.Extent.EndColumnNumber
                    [string]( '[{0}]' -f ( $accelerators.GetEnumerator() | Where-Object { $PSItem.Value.FullName -eq $typeName } ).Name )
                    [string]$TypeConstraintAst.Extent.File
                    [string]( "Consider changing '[{0}]' to '[{1}]'" -f $typeName, ( $accelerators.GetEnumerator() | Where-Object { $PSItem.Value.FullName -eq $typeName } ).Name )
                )

                $suggestedCorrections = New-Object System.Collections.ObjectModel.Collection['Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent']
                $suggestedCorrections.add( $correctionExtent ) | Out-Null

                [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                    Message              = ( Get-Help -Name $MyInvocation.MyCommand.Name ).Description.Text
                    Extent               = $TypeConstraintAst.Extent
                    RuleName             = $MyInvocation.InvocationName
                    Severity             = 'Warning'
                    ScriptPath           = $TypeConstraintAst.Extent.File
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
