if ( -not ( Get-Variable IsMacOS -ErrorAction SilentlyContinue -ValueOnly ) -and -not ( Get-Variable IsLinux -ErrorAction SilentlyContinue -ValueOnly ) )
{
    function sudo
    {
        $file, [string]$arguments = $args
        $psi = [System.Diagnostics.ProcessStartInfo]::new( $file )
        $psi.Arguments = $arguments
        $psi.Verb = "runas"
        $psi.WorkingDirectory = Get-Location
        [System.Diagnostics.Process]::Start( $psi ) | Out-Null
    }

    function touch($file)
    {
        "" | Out-File $file -Encoding ASCII
    }
    function mail
    {
        Start-Process "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
    }
}