# Find all trusted executables in System32
$paths = Get-ChildItem c:\windows\system32 -File | ForEach-Object { if($_ -match '.+?exe$') {Get-AuthenticodeSignature $_.fullname} } | where {$_.IsOSBinary} | ForEach-Object {$_.path }

# Executing these executables causes trouble, let's just skip them
$skips = "*shutdown*","*logoff*","*lsaiso*","*rdpinit*","*wininit*","*DeviceCredentialDeployment*","*lsass*"

# Prepare ProcessStartInfo object
$s = New-Object System.Diagnostics.ProcessStartInfo
# Update SYSTEMROOT variable, point it to our location
$s.EnvironmentVariables.Remove("SYSTEMROOT")
$s.EnvironmentVariables.Add("SYSTEMROOT", "C:\Temp")
$s.UseShellExecute = $false

# Prepare Process object
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $s

# Iterate over executables
foreach ($path in $paths) {
    $executable = Split-Path $path -Leaf
    if(($skips | where {$executable -Like $_})) { continue }
    # Set Process object's path to the current executable
    $s.FileName = $path
    # Start the process and move on
    $p.Start()
}
