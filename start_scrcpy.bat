@echo off
REM Aurora scrcpy Launcher
REM Startet scrcpy mit USB-Gerät in optimaler Auflösung

echo Starting scrcpy for Aurora development...
echo.

REM Prüfe ob scrcpy installiert ist
where scrcpy >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: scrcpy ist nicht installiert oder nicht im PATH!
    echo Bitte installiere scrcpy: https://github.com/Genymobile/scrcpy
    pause
    exit /b 1
)

REM Starte scrcpy mit USB-Gerät (Samsung SM-A145F)
REM -d = USB device (nicht Emulator)
REM --max-size 1024 = Optimale Auflösung für Entwicklung
REM --window-title = Fenstertitel
scrcpy -d --max-size 1024 --window-title "Aurora Timeline Test"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: scrcpy konnte nicht gestartet werden!
    echo.
    echo Mögliche Ursachen:
    echo - Kein USB-Gerät verbunden
    echo - USB-Debugging nicht aktiviert
    echo - Mehrere Geräte verbunden (verwende -s SERIAL)
    echo.
    pause
)
