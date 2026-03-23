<#
.SYNOPSIS
    Specifing a DefaultParameterSetName allows PowerShell to determine a parameter set to use if parameters are supplied positionally.
.DESCRIPTION
    Specify a DefaultParameterSetName when using multiple parameter sets. [CmdletBinding( DefaultParameterSetName = 'PARAMETERSETNAME' )]
.INPUTS
    [System.Management.Automation.Language.AttributeBaseAst]
.OUTPUTS
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]
#>
function PSUseDefaultParameterSetName
{
    [CmdletBinding()]
    [OutputType( [System.Object] ) ]
    [OutputType( [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord] ) ]
    param
    (
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ParamBlockAst]
        $ParamBlockAst
    )

    begin
    {
        Set-StrictMode -Version 2.0
    }

    process
    {
        try
        {
            [System.Management.Automation.Language.NamedAttributeArgumentAst[]]$namedAttribArg = $ParamBlockAst.FindAll( { $args[0] -is [System.Management.Automation.Language.NamedAttributeArgumentAst] }, $false )

            if ( [string]::IsNullOrWhiteSpace( $namedAttribArg ) -eq $false -and ( $namedAttribArg.ArgumentName -contains 'ParameterSetName' -and $namedAttribArg.ArgumentName -notcontains 'DefaultParameterSetName' ) )
            {
                [System.Management.Automation.Language.AttributeAst]$cmdletbinding = $ParamBlockAst.Attributes | Where-Object { $PSItem.TypeName.Name -eq 'CmdletBinding' }
                if ( [string]::IsNullOrWhiteSpace( $cmdletbinding ) -eq $false )
                {
                    [System.Management.Automation.Language.IScriptExtent]$extent = $cmdletbinding.Extent
                }
                else
                {
                    [System.Management.Automation.Language.IScriptExtent]$extent = $ParamBlockAst.Extent
                }

                [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                    Message  = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                    Extent   = $extent
                    RuleName = $MyInvocation.InvocationName
                    Severity = 'Warning'
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
