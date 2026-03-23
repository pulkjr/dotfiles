<#
.SYNOPSIS
    Tests if a function has a defined output type.
.DESCRIPTION
    All functions should specify an output type.  If the function has no output use [void] as it's output type.
.INPUTS
    [System.Management.Automation.Language.ScriptBlockAst]
.OUTPUTS
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
function PSUseOutputType
{
    [CmdletBinding()]
    [OutputType( [System.Object] )]
    [OutputType( [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord] ) ]
    param
    (
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.FunctionDefinitionAst]
        $FunctionDefinitionAst
    )

    begin
    {
        Set-StrictMode -Version 2.0
    }

    process
    {
        try
        {
            if ( $FunctionDefinitionAst.IsFilter -eq $true -or $FunctionDefinitionAst.IsWorkflow -eq $true )
            {
                return
            }

            [System.Management.Automation.Language.AttributeAst[]]$attribs = $FunctionDefinitionAst.FindAll( { $args[0] -is [System.Management.Automation.Language.AttributeAst] }, $true )

            if ( ( [string]::IsNullOrWhiteSpace( $attribs ) -eq $true ) -or ( $attribs.TypeName.Name -notcontains 'OutputType' -eq $true ) )
            {
                [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                    Message              = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                    Extent               = $FunctionDefinitionAst.Extent
                    RuleName             = $MyInvocation.InvocationName
                    Severity             = 'Warning'
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
