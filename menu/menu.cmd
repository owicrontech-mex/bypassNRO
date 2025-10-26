@echo off
chcp 1252 >nul
setlocal enabledelayedexpansion
set "DEST=C:\Windows\Panther"
set "NEWNAME=unattend.xml"

set "TOTAL_OPCIONES=4"

:: Opcion 1
set "URL_1=https://raw.githubusercontent.com/owicrontech-mex/bypassNRO/refs/heads/main/UserOwicron.xml"
set "NOMBRE_1=XML de Owicron Tech"
set "ARCHIVO_1=config1.xml"

:: Opcion 2
set "URL_2=https://raw.githubusercontent.com/owicrontech-mex/bypassNRO/refs/heads/main/menu/LocalAccount.xml"
set "NOMBRE_2=XML Cuenta Local con Bloatware"
set "ARCHIVO_2=config2.xml"

:: Opcion 3
set "URL_3=https://raw.githubusercontent.com/owicrontech-mex/bypassNRO/refs/heads/main/menu/LocalCuenta.xml"
set "NOMBRE_3=XML Cuenta Local sin Bloatware"
set "ARCHIVO_3=config3.xml"

:: Opcion 4
set "URL_3=https://raw.githubusercontent.com/ChrisTitusTech/bypassnro/refs/heads/main/unattend.xml"
set "NOMBRE_3=XML de ChrisTitusTech"
set "ARCHIVO_3=config4.xml"

:: Directorio temporal (en WinPE usa X:\Temp o C:\Temp si ya hay particion)
set "TEMP_DIR=C:\Temp"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%" 2>nul
::if not exist "%TEMP_DIR%" set "TEMP_DIR=C:\Temp"
::if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%" 2>nul

:MENU
cls
echo.
echo ===============================================================================
echo                     MENU DE SELECCION DE ARCHIVOS
echo                           [WinPE Compatible]
echo ===============================================================================
echo.

:: Mostrar opciones
for /l %%i in (1,1,%TOTAL_OPCIONES%) do (
    echo  [%%i] !NOMBRE_%%i!
)

echo  [0] Cancelar y salir
echo.
echo ===============================================================================
echo.

set /p "CHOICE_INDEX=Elige el número deseado: "

rem --- Validar entrada: vacía, texto o fuera de rango ---
if "%CHOICE_INDEX%"=="" goto MENU
for /f "delims=0123456789" %%X in ("%CHOICE_INDEX%") do (
    echo Opción inválida. Solo números.
    pause >nul
    goto MENU
)
if %CHOICE_INDEX% LSS 0 goto MENU
if %CHOICE_INDEX% GTR %TOTAL_OPCIONES% (
    echo Opción fuera de rango.
    pause >nul
    goto MENU
)
if %CHOICE_INDEX% EQU 0 (
    echo Operación cancelada por el usuario.
    exit /b 0
)

SET "URL_SELECTED=!URL_%CHOICE_INDEX%!"
SET "NOMBRE_SELECTED=!NOMBRE_%CHOICE_INDEX%!"
SET "ARCHIVO_SELECTED=!ARCHIVO_%CHOICE_INDEX%!"
SET "RUTA_COMPLETA=%TEMP_DIR%\!ARCHIVO_%CHOICE_INDEX%!"

echo Verificando URL...
set "RESULTADO="
set "URL_VALIDA=0"
for /f "tokens=2" %%H in (
    'curl -s -L -k -I "%URL_SELECTED%" 2^>nul ^| findstr /c:"HTTP/"'
) do (
    set "RESULTADO=%%H"
)
if /i "!RESULTADO!"=="200" set "URL_VALIDA=1"
if /i "!RESULTADO!"=="302" set "URL_VALIDA=1"
if /i "!RESULTADO!"=="301" set "URL_VALIDA=1"
if /i "!RESULTADO!"=="307" set "URL_VALIDA=1"

if "!URL_VALIDA!"=="0" (
    echo [ERROR] URL inaccesible o no existe.
    ping -n 3 127.0.0.1 >nul
    goto MENU
)

echo Descargando "!NOMBRE_SELECTED!"...
curl -s -L -k -o "%RUTA_COMPLETA%" "%URL_SELECTED%"
if errorlevel 1 (
    echo [ERROR] No se pudo descargar el archivo desde "!URL_SELECTED!".
    goto MENU
)
if not exist "%DEST%" md "%DEST%" >nul 2>&1

echo Copiando "%ARCHIVO_SELECTED%" como "%NEWNAME%"...
copy "!RUTA_COMPLETA!" "%DEST%\%NEWNAME%" >nul || (
    echo [ERROR] No se pudo copiar y renombrar el archivo.
    exit /b 3
)
del "!RUTA_COMPLETA!" >nul 2>&1
echo [OK] "%ARCHIVO_SELECTED%" copiado correctamente a "%DEST%\%NEWNAME%".
echo.
echo El proceso ha finalizado. El sistema se reiniciará en breve...
ping -n 4 127.0.0.1 >nul
echo.
rem === Sysprep opcional (descomentar si se desea ejecutar) ===
%WINDIR%\System32\Sysprep\Sysprep.exe /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot

endlocal
