<#
.Synopsis
    Modifing the user's enviornment can cause behavior the user does not expect.
.Description
    Do not modify the user's Execution Policy.
.Inputs
    [System.Management.Automation.Language.ScriptBlockAst]
.Outputs
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
function PSAvoidModifyingExecutionPolicy
{
    [CmdletBinding()]
    [OutputType( [System.Object[]] ) ]
    [OutputType( [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord] ) ]
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
            if ( $CommandAst.GetCommandName() -eq 'Set-ExecutionPolicy' )
            {
                [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                    Message              = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                    Extent               = $CommandAst.Extent
                    RuleName             = $MyInvocation.InvocationName
                    Severity             = 'Error'
                    SuggestedCorrections = $null
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
