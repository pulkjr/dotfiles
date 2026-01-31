<#
.SYNOPSIS
    Tests if a function uses [CmdletBinding()].
.DESCRIPTION
    Using [CmdletBinding()] in functions allows them to accept Common Parameters.
.INPUTS
    [System.Management.Automation.Language.ScriptBlockAst]
.OUTPUTS
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
function PSUseCmdletBinding
{
    [CmdletBinding()]
    [OutputType( [System.Object] ) ]
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
            if ( $FunctionDefinitionAst.IsFilter -eq $false -and $FunctionDefinitionAst.IsWorkflow -eq $false )
            {
                [System.Management.Automation.Language.AttributeAst[]]$attribs = $FunctionDefinitionAst.FindAll( { $args[0] -is [System.Management.Automation.Language.AttributeAst] }, $true )
                if ( ( [string]::IsNullOrWhiteSpace( $attribs ) -eq $true ) -or ( $attribs.TypeName.Name -notcontains 'CmdletBinding' -eq $true ) )
                {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        Message  = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                        Extent   = $FunctionDefinitionAst.Extent
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
