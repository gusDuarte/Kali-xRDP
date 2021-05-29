# WSL2 + Ubuntu 20.04 + Gnome

Gnome-Xserver es un script que configura WSL2 e instala Ubuntu 20.04 con Gnome como entorno grafico.

Esta basado en el proyecto "Kali-xRDP (https://github.com/DesktopECHO/Kali-xRDP) y esta guía https://levelup.gitconnected.com/install-ubuntu-desktop-gui-in-wsl2-7c3730e33bb2.


**INSTRUCCIONES:  Abrir un command prompt de Windows con permisos de Administrador, copie y pegue el siguiente comando:**

## GNOME
    PowerShell -executionpolicy bypass -command "wget https://github.com/gusDuarte/Kali-xRDP/raw/main/Gnome-Xserver.cmd -UseBasicParsing -OutFile Gnome-Xserver.cmd ; .\Gnome-Xserver.cmd"

## Mate WSL1
    PowerShell -executionpolicy bypass -command "wget https://github.com/gusDuarte/Kali-xRDP/raw/main/Mate-Xserver.cmd -UseBasicParsing -OutFile Mate-Xserver.cmd ; .\Mate-Xserver.cmd"

## Mate WSL2
    PowerShell -executionpolicy bypass -command "wget https://github.com/gusDuarte/Kali-xRDP/raw/main/Mate-Xsrv-WSL2.cmd -UseBasicParsing -OutFile Mate-Xsrv-WSL2.cmd ; .\Mate-Xserver.cmd"