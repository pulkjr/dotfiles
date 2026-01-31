<#
.Synopsis
    To enforce good coding practices Set-StrictMode should be used.
.Description
    To enforce good coding practices Set-StrictMode should be used.
.Inputs
    [System.Management.Automation.Language.ScriptBlockAst]
.Outputs
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
function PSUseSetStrictMode
{
    [CmdletBinding()]
    [OutputType( [System.Object] ) ]
    [OutputType( [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord] ) ]
    param
    (
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Version = '2'
    )

    begin
    {
        Set-StrictMode -Version 2.0
    }

    process
    {
        if ( [string]::IsNullOrEmpty( $ScriptBlockAst.Parent ) -eq $false )
        {
            return
        }

        [System.Management.Automation.Language.CommandAst[]]$commandStrictMode = $ScriptBlockAst.FindAll( { $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true ).Where( { $PSItem.GetCommandName() -eq 'Set-StrictMode' } )

        if ( [string]::IsNullOrWhiteSpace( $commandStrictMode ) -eq $true )
        {
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                Message  = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                Extent   = $ScriptBlockAst.Extent
                RuleName = $MyInvocation.InvocationName
                Severity = 'Warning'
            }
        }
        else
        {
            foreach ( $command in $commandStrictMode  )
            {
                if ( $command.CommandElements.Where( { $PSItem -is [System.Management.Automation.Language.CommandParameterAst] } ).ParameterName -eq 'Off' -or $command.Extent.Text -notmatch $Version )
                {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        Message  = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                        Extent   = $command.Extent
                        RuleName = $MyInvocation.InvocationName
                        Severity = 'Warning'
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
