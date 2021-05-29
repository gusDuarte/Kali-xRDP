
ECHO [%TIME:~0,8%] Check if WSL is enabled, if not, enable and RESTART !!!.
PowerShell.exe -Command "$WSL = Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' ; if ($WSL.State -eq 'Disabled') {dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart; Restart-Computer }"
SET RUNSTART=%date% @ %time:~0,5%

ECHO:
ECHO [%TIME:~0,8%] Check if Virtual Machine feature is enabled, it not, enable and RESTART !!!
PowerShell.exe -Command "IF (Test-Path $env:TEMP\vmenable.TMP) {$do = Get-Content $env:TEMP\vmenable.TMP} ELSE {$do = 'no'}; IF ($do -ne 'done') {dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart; ECHO 'done' > $env:TEMP\vmenable.TMP; Restart-Computer }"

ECHO:
ECHO [%TIME:~0,8%] Download and Install Linux Kernel Update
PowerShell.exe -Command "IF (Test-Path $env:TEMP\kernelupdate.TMP) {$do = Get-Content $env:TEMP\kernelupdate.TMP} ELSE {$do = 'no'}; IF ($do -ne 'done') {Start-BitsTransfer -Source https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -Destination $env:TEMP\wsl_update_x64.msi ; Start-Process $env:TEMP\wsl_update_x64.msi -ArgumentList '/quiet /passive'; ECHO 'done' > $env:TEMP\kernelupdate.TMP }"

ECHO:
ECHO [%TIME:~0,8%] Set WSL version 2.
PowerShell.exe -Command  "wsl --set-default-version 2"