<#
.SYNOPSIS
    Tests if a function sets Mandatory to False for optional parameters.
.DESCRIPTION
    The default value for Mandatory is False unless set to True. Do not set Mandatory to false on optional parameters, instead omit the option.
.INPUTS
    [System.Management.Automation.Language.ScriptBlockAst]
.OUTPUTS
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
function PSAvoidUseOfMandatoryFalse
{
    [CmdletBinding()]
    [OutputType( [Object[]] ) ]
    param
    (
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
        try
        {
            [ScriptBlock]$predicate1 = {
                param ( [System.Management.Automation.Language.Ast]$Ast )
                [bool]$returnValue = $false
                if ( $Ast -is [System.Management.Automation.Language.AttributeBaseAst] )
                {
                    [System.Management.Automation.Language.AttributeBaseAst]$attributeList = $Ast
                    foreach ( $attribute in $attributeList )
                    {
                        if ( $attribute.TypeName.Name -eq 'Parameter' )
                        {
                            foreach ( $namedArg in $attribute.NamedArguments )
                            {
                                if ( $namedArg.ArgumentName -eq 'Mandatory' -and
                                    ( $namedArg.Argument.Extent.Text -eq '$false' -or
                                        ( $namedArg.Argument[0].PSObject.Properties.Name -contains 'Value' -and [convert]::ToBoolean( $namedArg.Argument[0].Value ) -eq $false ) ) )
                                {
                                    $returnValue = $true
                                }
                            }
                        }
                    }
                }
                return $returnValue
            }

            $results = @()
            [System.Management.Automation.Language.Ast[]]$violations = @( $ScriptBlockAst.FindAll( $predicate1, $false ) )

            if ( $violations.Count -ne 0 )
            {
                foreach ( $violation in $violations )
                {
                    [regex]$pattern1 = '\s*Mandatory\s*=\s*.[^\)\r\n]*'
                    [regex]$pattern2 = '\r\n\s*'
                    $replaceTest = $pattern2.Replace( ( $pattern1.Replace( $violation.Extent.Text, '' ) ), ' ', 1 )

                    $correctionExtent = New-Object 'Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent' @(
                        [int]$violation.Extent.StartLineNumber,
                        [int]$violation.Extent.EndLineNumber,
                        [int]$violation.Extent.StartColumnNumber,
                        [int]$violation.Extent.EndColumnNumber,
                        [string]"$replaceTest",
                        [string]$violation.Extent.File,
                        [string]'Remove setting Mandatory option.'
                    )

                    $suggestedCorrections = New-Object System.Collections.ObjectModel.Collection['Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent']
                    $suggestedCorrections.add( $correctionExtent ) | Out-Null

                    $result = [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        'Message'              = $( ( Get-Help $MyInvocation.MyCommand.Name ).Description.Text )
                        'Extent'               = $violation.Extent
                        'RuleName'             = $MyInvocation.InvocationName
                        'Severity'             = 'Warning'
                        'SuggestedCorrections' = $suggestedCorrections
                    }
                    $results += $result
                }
            }

            return $results
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError( $PSItem )
        }
    }

    end
    { 
    }
}

if ( $MyInvocation.ScriptName -match '.psm1$' )
{
    Export-ModuleMember -Function $( Split-Path -Path $PSCommandPath -Leaf ).Replace( '.ps1', '' )
}
