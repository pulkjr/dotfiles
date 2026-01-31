Get-ChildItem -Path "$PSScriptRoot\Rules\*.ps1" | Where-Object { $PSItem.Name -like '*.ps1' } | ForEach-Object { . $PSItem }
