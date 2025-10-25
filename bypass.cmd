curl -L -o C:\Windows\Panther\unattend.xml https://raw.githubusercontent.com/owicrontech-mex/bypassNRO/refs/heads/main/UserOwicron.xml
%WINDIR%\System32\Sysprep\Sysprep.exe /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot
