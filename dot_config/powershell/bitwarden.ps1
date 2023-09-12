[string]$bwString = Invoke-Expression -Command 'bw unlock'
[string]$bwSessionCommand = ( $bwstring | Select-String '>' ) -replace '> '

Invoke-Expression -Command $bwSessionCommand

[string] $cmciUserName = (bw get "username" "cmci")
if ( -not ([string]::IsNullOrEmpty( $cmciUserName ) ) )
{
    [pscredential]$cmci = [PSCredential]::new($cmciUserName, ( ConvertTo-SecureString -String (bw get "password" "cmci") -AsPlainText ))
}
else
{
    Write-Host -ForegroundColor Red "CMCI username not present"
}

[string] $dmciUserName = (bw get "username" "dmci")
if ( -not ([string]::IsNullOrEmpty( $dmciUserName ) ) )
{
    [pscredential]$dmci = [PSCredential]::new($dmciUserName, ( ConvertTo-SecureString -String (bw get "password" "dmci") -AsPlainText ))
}
else
{
    Write-Host -ForegroundColor Red "DMCI username not present"
}