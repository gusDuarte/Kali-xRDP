Write-Output "Check if WSL is enabled, if not, enable and RESTART !!!"

$WSL = Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux';
if ($WSL.State -eq 'Disabled')
{
  dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart;
  Restart-Computer;
}

Write-Output "Check if Virtual Machine feature is enabled, it not, enable and RESTART !!!"
IF (Test-Path $env:TEMP\vmenable.TMP)
{
  dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart;
  Write-Output 'done' > $env:TEMP\vmenable.TMP; Restart-Computer;
  New-Item -Path $env:TEMP -Name "vmenable.TMP" -ItemType "file";
  Restart-Computer;
}

Write-Output "Download and Install Linux Kernel Update"
IF (Test-Path $env:TEMP\kernelupdate.TMP)
{
  Start-BitsTransfer -Source https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -Destination $env:TEMP\wsl_update_x64.msi ;
  Start-Process $env:TEMP\wsl_update_x64.msi -ArgumentList '/quiet /passive';
  New-Item -Path $env:TEMP -Name kernelupdate.TMP -ItemType "file"
}

Write-Output "Set WSL version 2."
PowerShell.exe -Command  "wsl --set-default-version 2"