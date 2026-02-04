@echo off
echo Enabling PHP fileinfo extension...
echo.

set PHP_INI=C:\tools\php83\php.ini

echo Checking if fileinfo extension is commented out...
findstr /C:";extension=fileinfo" "%PHP_INI%" >nul 2>&1

if %errorlevel%==0 (
    echo Found commented fileinfo extension. Enabling it...
    powershell -Command "(gc '%PHP_INI%') -replace ';extension=fileinfo', 'extension=fileinfo' | Out-File -encoding ASCII '%PHP_INI%'"
    echo fileinfo extension enabled!
) else (
    findstr /C:"extension=fileinfo" "%PHP_INI%" >nul 2>&1
    if %errorlevel%==0 (
        echo fileinfo extension is already enabled.
    ) else (
        echo Adding fileinfo extension to php.ini...
        echo extension=fileinfo >> "%PHP_INI%"
        echo fileinfo extension added!
    )
)

echo.
echo Please restart your terminal and try setup again.
pause
