@ECHO OFF & NET SESSION >NUL 2>&1
IF %ERRORLEVEL% == 0 (ECHO Administrator check passed...) ELSE (ECHO You need to run this command with administrative rights.  Is User Account Control enabled? && pause && goto ENDSCRIPT)

SET GITORG=gusDuarte
SET GITPRJ=Kali-xRDP
SET BRANCH=main
SET BASE=https://github.com/%GITORG%/%GITPRJ%/raw/%BRANCH%
SET DISTRO=Ubuntu

REM ## Enable WSL if needed
PowerShell.exe -Command "$WSL = Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' ; if ($WSL.State -eq 'Disabled') {Enable-WindowsOptionalFeature -FeatureName $WSL.FeatureName -Online}"
SET RUNSTART=%date% @ %time:~0,5%

REM ## Install Ubuntu from AppStore if needed
PowerShell.exe -Command "wsl -d %DISTRO% -e 'uname' > $env:TEMP\DistroTestAlive.TMP ; $alive = Get-Content $env:TEMP\DistroTestAlive.TMP ; IF ($Alive -ne 'Linux') { Start-BitsTransfer https://aka.ms/wslubuntu2004 -Destination $env:TEMP\Ubuntu2004.AppX ; Add-AppxPackage $env:TEMP\Ubuntu2004.AppX ; Ubuntu.exe install --root }"


REM ## Acquire LxRunOffline
IF NOT EXIST "%TEMP%\LxRunOffline.exe" POWERSHELL.EXE -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; wget https://github.com/DDoSolitary/LxRunOffline/releases/download/v3.5.0/LxRunOffline-v3.5.0-msvc.zip -UseBasicParsing -OutFile '%TEMP%\LxRunOffline-v3.5.0-msvc.zip' ; Expand-Archive -Path '%TEMP%\LxRunOffline-v3.5.0-msvc.zip' -DestinationPath '%TEMP%' -Force" > NUL
MKDIR %TEMP%\Kali-xRDP >NUL 2>&1

REM ## Install .NET 5.0 Runtime
PowerShell.exe -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
PowerShell.exe -Command "choco install dotnet-5.0-runtime -y"

REM ## Insall Xserver


REM ## Find system DPI setting and get installation parameters
IF NOT EXIST "%TEMP%\windpi.ps1" POWERSHELL.EXE -ExecutionPolicy Bypass -Command "wget '%BASE%/windpi.ps1' -UseBasicParsing -OutFile '%TEMP%\windpi.ps1'"
FOR /f "delims=" %%a in ('powershell -ExecutionPolicy bypass -command "%TEMP%\windpi.ps1" ') do set "WINDPI=%%a"



ECHO [Ubuntu Gnome-Xserver Installer 20210521]
ECHO:

SET DISTROFULL=%temp%
CD %DISTROFULL%
%TEMP%\LxRunOffline.exe su -n %DISTRO% -v 0
SET GO="%DISTROFULL%\LxRunOffline.exe" r -n "%DISTRO%" -c

POWERSHELL.EXE -Command "wget %BASE%/excludeWSL.ps1 -UseBasicParsing -OutFile '%DISTROFULL%\excludeWSL.ps1'" & START /WAIT /MIN "Add exclusions in Windows Defender" "POWERSHELL.EXE" "-ExecutionPolicy" "Bypass" "-Command" ".\excludeWSL.ps1" "%DISTROFULL%" &  DEL ".\excludeWSL.ps1"

REM ## Workaround potential DNS issues in WSL
%GO% "rm -rf /etc/resolv.conf ; echo 'nameserver 1.1.1.1' > /etc/resolv.conf ; echo 'nameserver 8.8.8.8' >> /etc/resolv.conf ; chattr +i /etc/resolv.conf" >NUL 2>&1

REM ## Loop until we get a successful repo update
:APTRELY
IF EXIST apterr DEL apterr
START /MIN /WAIT "apt-get update" %GO% "apt-get update 2> apterr"
FOR /F %%A in ("apterr") do If %%~zA NEQ 0 GOTO APTRELY

ECHO:
ECHO [%TIME:~0,8%] Prepare Distro (~30s)
REM ## Install apt-fast
%GO% "DEBIAN_FRONTEND=noninteractive apt-get -y install git gnupg2 libc-ares2 libssh2-1 libaria2-0 aria2 --no-install-recommends ; cd /tmp ; rm -rf %GITPRJ% ; git clone -b %BRANCH% --depth=1 https://github.com/%GITORG%/%GITPRJ%.git ; chmod +x /tmp/Kali-xRDP/dist/usr/local/bin/apt-fast ; cp -p /tmp/Kali-xRDP/dist/usr/local/bin/apt-fast /usr/local/bin" > "%TEMP%\Kali-xRDP\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Prepare Distro.log" 2>&1

REM ## Install Gnome-Desktop
ECHO [%TIME:~0,8%] Install Gnome desktop metapackage (~4m00s)
%GO% "DEBIAN_FRONTEND=noninteractive apt-fast -y install ubuntu-desktop --no-install-recommends"  > "%TEMP%\Kali-xRDP\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Gnome desktop.log" 2>&1

REM ## Adding extra repos
ECHO [%TIME:~0,8%] Adding extra repos (~30s)
%GO% "username=$(wslvar USERNAME);mkdir --parents /mnt/c/users/$username/.ubuntu/;cd /mnt/c/users/$username/.ubuntu; apt-key adv --fetch-keys https://packages.microsoft.com/keys/microsoft.asc; echo 'deb [arch=amd64] https://packages.microsoft.com/ubuntu/20.04/prod focal main' > /etc/apt/sources.list.d/microsoft-prod.list; apt update; apt upgrade -y" > "%TEMP%\Kali-xRDP\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Adding extra repos.log" 2>&1

REM ## Adding extra repos
ECHO [%TIME:~0,8%] Adding extra repos 2 (~30s)
%GO% "apt install -y apt-transport-https; wget --output-document /etc/apt/trusted.gpg.d/wsl-transdebian.gpg https://arkane-systems.github.io/wsl-transdebian/apt/wsl-transdebian.gpg; chmod a+r /etc/apt/trusted.gpg.d/wsl-transdebian.gpg; echo 'deb https://arkane-systems.github.io/wsl-transdebian/apt/ focal main' > /etc/apt/sources.list.d/wsl-transdebian.list; echo 'deb-src https://arkane-systems.github.io/wsl-transdebian/apt/ focal main' >> /etc/apt/sources.list.d/wsl-transdebian.list;" > "%TEMP%\Kali-xRDP\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Adding extra repos2.log" 2>&1


REM ## Create ceibal user
ECHO [%TIME:~0,8%] Create Ceibal user (~3s)
%GO% "useradd -m -s /bin/bash; echo 'ceibal:ceibal' | chpasswd; usermod -aG sudo ceibal" > "%TEMP%\Kali-xRDP\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Create Ceibal user.log" 2>&1

REM ## Install Genie
ECHO [%TIME:~0,8%] Install Genie (~3s)
%GO% "apt update; apt install --yes systemd-genie" > "%TEMP%\Kali-xRDP\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Install Genie.log" 2>&1
%GO% "echo 'ceibal ALL=(ALL) NOPASSWD:/usr/bin/genie' |  EDITOR='tee' visudo --file /etc/sudoers.d/ceibal" > "%TEMP%\Kali-xRDP\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Add Genie to sudoers.log" 2>&1

REM ## Create Start scripts
PowerShell.exe -ExecutionPolicy bypass -command "wget '%BASE%/01_reload_vcxsrv.ps1' -UseBasicParsing -OutFile '$env:userprofile\.ubuntu\01_reload_vcxsrv.ps1'"
PowerShell.exe -ExecutionPolicy bypass -command "wget '%BASE%/02_start_desktop.sh' -UseBasicParsing -OutFile '$env:userprofile\.ubuntu\02_start_desktop.sh'"
PowerShell.exe -ExecutionPolicy bypass -command "wget '%BASE%/03_start_ubuntu.vbs' -UseBasicParsing -OutFile '$env:userprofile\.ubuntu\03_start_ubuntu.vbs'"

PowerShell.exe -ExecutionPolicy bypass -command "wget '%BASE%/CreateShortcutIcon.ps1' -UseBasicParsing -OutFile '%TEMP%\CreateShortcutIcon.ps1'"
PowerShell.exe -ExecutionPolicy bypass -command "%TEMP%/CreateShortcutIcon.ps1"

SET RUNEND=%date% @ %time:~0,5%
CD %DISTROFULL%
ECHO:
ECHO:Installation of (%DISTRO%) complete

CD ..
ECHO:
:ENDSCRIPT
