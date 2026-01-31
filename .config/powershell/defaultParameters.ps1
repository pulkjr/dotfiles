$PSDefaultParameterValues = @{
    "Format-Table:AutoSize"           = $True
    "Select-String:AllMatches"        = $True
    "Get-Ntap*:Verbose"               = $True
    "Test-Connection:Quiet"           = $True
    "Test-Connection:Count"           = "1"
    'ConvertTo-Csv:NoTypeInformation' = $true
    'Install-Module:AllowClobber'     = $true
    'Receive-Job:Keep'                = $true
}