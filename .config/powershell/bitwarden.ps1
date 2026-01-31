Write-Host -ForegroundColor DarkGray 'Unlocking Bitwarden Vault for this session. Please provide the master key.'
[string]$bwString = Invoke-Expression -Command 'bw unlock'

Invoke-Expression -Command ([regex]::match($bwString, '\$env:BW_SESSION=\".+?\"').Value)
Remove-Variable -Name 'bwString' -ErrorAction SilentlyContinue

if (  $env:BW_SESSION )
{
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
}