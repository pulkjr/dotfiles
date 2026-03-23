<#
.Synopsis
    If a function supports the use of the pipeline, the process block must be specified.
.Description
    Specify a process block when supporting the pipeline.
.Inputs
    [System.Management.Automation.Language.FunctionDefinitionAst]
.Outputs
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]
#>
function PSUseProcessBlockAppropriatly
{
    [CmdletBinding()]
    [OutputType( [System.Object] ) ]
    [OutputType( [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord] ) ]
    param
    (
        # Specify a Function Definition Ast to test.
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.FunctionDefinitionAst]
        $FunctionDefinitionAst
    )

    begin
    {
        Set-StrictMode -Version 2.0

        <#
        .Description
            Filters Named Attribute Argument Asts to ValueFromPipeline and ValueFromPipelineByPropertyName where the value is true.
        #>
        filter ArgumentFilter
        {
            [System.Management.Automation.Language.NamedAttributeArgumentAst]$namedAttrib = $PSItem
            if ( $namedAttrib.ArgumentName -match '^ValueFromPipeline' )
            {
                if ( $namedAttrib.Argument[0].PSObject.Properties.Name -contains 'Value' -and $namedAttrib.Argument.Value -eq $true )
                {
                    $namedAttrib
                }

                if ( $PSItem.Argument[0].PSObject.Properties.Name -contains 'VariablePath' -and [convert]::ToBoolean( $PSItem.Argument.VariablePath.ToString() ) -eq $true )
                {
                    $namedAttrib
                }
            }
        }
    }

    process
    {
        try
        {
            if ( $FunctionDefinitionAst.IsFilter -eq $true -or $FunctionDefinitionAst.IsWorkflow -eq $true )
            {
                return
            }

            foreach ( $paramBlock in $FunctionDefinitionAst.Body.ParamBlock )
            {
                [System.Management.Automation.Language.NamedAttributeArgumentAst[]]$pipelineAttrib = $paramBlock.FindAll( { $args[0] -is [System.Management.Automation.Language.NamedAttributeArgumentAst] }, $true ) | ArgumentFilter

                if ( [string]::IsNullOrWhiteSpace( $pipelineAttrib ) -eq $false -and [string]::IsNullOrWhiteSpace( $FunctionDefinitionAst.Body.ProcessBlock ) -eq $true )
                {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        Message  = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                        Extent   = $paramBlock.Extent
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
