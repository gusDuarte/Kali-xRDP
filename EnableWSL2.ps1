Write-Output "Check if WSL is enabled, if not, enable and RESTART !!!"

$WSL = Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux';
if ($WSL.State -eq 'Disabled')
{
  Write-Output "Enabling WSL feature ..."
  dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart;
  Restart-Computer;
}

Write-Output "Check if Virtual Machine feature is enabled ..."
$r = Test-Path $env:TEMP\vmenable.TMP
IF ($r -eq $false)
{
  Write-Output "Enable VM and RESTART !!!"
  dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart;
  Write-Output 'done' > $env:TEMP\vmenable.TMP; Restart-Computer;
  New-Item -Path $env:TEMP -Name "vmenable.TMP" -ItemType "file";
  Restart-Computer;
}

Write-Output "Check if Linux Kernel Update is installed ..."
$r = Test-Path $env:TEMP\kernelupdate.TMP
IF ($r -eq $false)
{
  Write-Output "Download and Install Linux Kernel Update"
  Start-BitsTransfer -Source https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -Destination $env:TEMP\wsl_update_x64.msi ;
  Start-Process $env:TEMP\wsl_update_x64.msi -ArgumentList '/quiet /passive';
  New-Item -Path $env:TEMP -Name kernelupdate.TMP -ItemType "file"
}

Write-Output "Set WSL version 2."
PowerShell.exe -Command  "wsl --set-default-version 2"