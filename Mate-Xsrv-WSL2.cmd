@ECHO OFF & NET SESSION >NUL 2>&1
IF %ERRORLEVEL% == 0 (ECHO Administrator check passed...) ELSE (ECHO You need to run this command with administrative rights.  Is User Account Control enabled? && pause && goto ENDSCRIPT)

SET GITORG=gusDuarte
SET GITPRJ=Kali-xRDP
SET BRANCH=main
SET BASE=https://github.com/%GITORG%/%GITPRJ%/raw/%BRANCH%
SET DISTRO=Ubuntu-20.04

ECHO [Ubuntu Gnome-Xserver Installer 20210521]
ECHO:
ECHO:

REM ##
REM ## Enable WSL2
REM ##
PowerShell.exe -ExecutionPolicy bypass -command "Start-BitsTransfer -Source '%BASE%/EnableWSL2.ps1' -Destination $env:TEMP\EnableWSL2.ps1;"
PowerShell.exe -ExecutionPolicy bypass -command "%TEMP%\EnableWSL2.ps1"




ECHO:
ECHO [%TIME:~0,8%] Install Ubuntu from AppStore if needed
PowerShell.exe -Command "wsl -d %DISTRO% -e 'uname' > $env:TEMP\DistroTestAlive.TMP ; $alive = Get-Content $env:TEMP\DistroTestAlive.TMP ; IF ($Alive -ne 'Linux') { Start-BitsTransfer -Source https://aka.ms/wslubuntu2004 -Destination $env:TEMP\Ubuntu2004.AppX ; Add-AppxPackage $env:TEMP\Ubuntu2004.AppX ; Ubuntu2004.exe install --root }"

ECHO:
ECHO [%TIME:~0,8%] Acquire LxRunOffline
IF NOT EXIST "%TEMP%\LxRunOffline.exe" POWERSHELL.EXE -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; Start-BitsTransfer -Source https://github.com/DDoSolitary/LxRunOffline/releases/download/v3.5.0/LxRunOffline-v3.5.0-msvc.zip -Destination '%TEMP%\LxRunOffline-v3.5.0-msvc.zip' ; Expand-Archive -Path '%TEMP%\LxRunOffline-v3.5.0-msvc.zip' -DestinationPath '%TEMP%' -Force" > NUL
MKDIR %TEMP%\Kali-xRDP >NUL 2>&1

ECHO:
ECHO [%TIME:~0,8%] Install chocolatey
PowerShell.exe -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

ECHO:
ECHO [%TIME:~0,8%] Install .NET 5.0 Runtime
PowerShell.exe -Command "choco install dotnet-5.0-runtime -y"
ECHO:
ECHO [%TIME:~0,8%] Insall Xserver
PowerShell.exe -Command "choco install vcxsrv -y"


SET DISTROFULL=%temp%
CD %DISTROFULL%
%TEMP%\LxRunOffline.exe su -n %DISTRO% -v 0
SET GO="%DISTROFULL%\LxRunOffline.exe" r -n "%DISTRO%" -c

ECHO:
ECHO [%TIME:~0,8%] Loop until we get a successful repo update
:APTRELY
IF EXIST apterr DEL apterr
START /MIN /WAIT "apt-get update" %GO% "apt-get update 2> apterr"
FOR /F %%A in ("apterr") do If %%~zA NEQ 0 GOTO APTRELY


ECHO:
ECHO [%TIME:~0,8%] Upgrade distro packages (~5m00s)
REM ## Install apt-fast
%GO% "DEBIAN_FRONTEND=noninteractive apt upgrade -y; DEBIAN_FRONTEND=noninteractive apt-get -y install git gnupg2 libc-ares2 libssh2-1 libaria2-0 aria2 --no-install-recommends ; cd /tmp ; rm -rf %GITPRJ% ; git clone -b %BRANCH% --depth=1 https://github.com/%GITORG%/%GITPRJ%.git ; chmod +x /tmp/Kali-xRDP/dist/usr/local/bin/apt-fast ; cp -p /tmp/Kali-xRDP/dist/usr/local/bin/apt-fast /usr/local/bin" > "%TEMP%\Kali-xRDP\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Prepare Distro.log" 2>&1

REM ## Install MATE-Desktop
ECHO [%TIME:~0,8%] Install Mate desktop metapackage (~4m00s)

@REM ## Classic Mate fashion
%GO% "DEBIAN_FRONTEND=noninteractive apt-fast -y install  --no-install-recommends ubuntu-mate-core ubuntu-mate-desktop"  > "%TEMP%\Kali-xRDP\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Mate desktop.log" 2>&1

@REM ## Ubuntu Mate fashion
@REM %GO% "DEBIAN_FRONTEND=noninteractive apt-fast -y install --no-install-recommends mate-desktop-environment mate-desktop-environment-extra"  > "%TEMP%\Kali-xRDP\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Mate desktop.log" 2>&1

ECHO:
ECHO [%TIME:~0,8%] Create Ceibal user (~3s)
%GO% "useradd -m -s /bin/bash ceibal; echo 'ceibal:ceibal' | chpasswd; usermod -aG sudo ceibal" > "%TEMP%\Kali-xRDP\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Create Ceibal user.log" 2>&1
%GO% "echo 'ceibal ALL=(ALL) NOPASSWD:ALL' |  EDITOR='tee' visudo --file /etc/sudoers.d/ceibal" > "%TEMP%\Kali-xRDP\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Add user Ceibal to sudoers.log" 2>&1
Ubuntu2004.exe config --default-user ceibal

ECHO:
ECHO [%TIME:~0,8%] Create startup scripts (~3s)
%GO% "username=$(wslvar USERNAME);mkdir --parents /mnt/c/users/$username/.ubuntu/"
PowerShell.exe -ExecutionPolicy bypass -command "Start-BitsTransfer -Source '%BASE%/01_reload_vcxsrv.ps1' -Destination $env:userprofile\.ubuntu\01_reload_vcxsrv.ps1"
PowerShell.exe -ExecutionPolicy bypass -command "Start-BitsTransfer -Source '%BASE%/02_start_mate.sh' -Destination $env:userprofile\.ubuntu\02_start_mate.sh"
PowerShell.exe -ExecutionPolicy bypass -command "Start-BitsTransfer -Source '%BASE%/03_start_mate.vbs' -Destination $env:userprofile\.ubuntu\03_start_mate.vbs"
PowerShell.exe -ExecutionPolicy bypass -command "Start-BitsTransfer -Source '%BASE%/ubuntu.ico' -Destination $env:userprofile\.ubuntu\ubuntu.ico"

%GO% "username=$(wslvar USERNAME); sed -i 's/USER_WIN/'"$username"'/g' /mnt/c/users/$username/.ubuntu/03_start_mate.vbs"

PowerShell.exe -ExecutionPolicy bypass -command "Start-BitsTransfer -Source '%BASE%/CreateShortcutIcon-mate.ps1' -Destination %TEMP%\CreateShortcutIcon-mate.ps1"
PowerShell.exe -ExecutionPolicy bypass -command "%TEMP%/CreateShortcutIcon-mate.ps1"

ECHO:
ECHO [%TIME:~0,8%] Reiniciando WSL ...
wsl --shutdown
%GO% "exit"

SET RUNEND=%date% @ %time:~0,5%
CD %DISTROFULL%
ECHO:
ECHO:Installation of (%DISTRO%) complete

CD ..
ECHO:
:ENDSCRIPT
