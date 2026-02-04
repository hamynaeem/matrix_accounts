@echo off
echo Enabling PHP MySQL extensions...
echo.

set PHP_INI=C:\tools\php83\php.ini

echo Checking and enabling required extensions...

REM Enable pdo_mysql
findstr /C:";extension=pdo_mysql" "%PHP_INI%" >nul 2>&1
if %errorlevel%==0 (
    echo Enabling pdo_mysql...
    powershell -Command "(gc '%PHP_INI%') -replace ';extension=pdo_mysql', 'extension=pdo_mysql' | Out-File -encoding ASCII '%PHP_INI%'"
) else (
    findstr /C:"extension=pdo_mysql" "%PHP_INI%" >nul 2>&1
    if %errorlevel%==0 (
        echo pdo_mysql is already enabled
    ) else (
        echo Adding pdo_mysql extension...
        echo extension=pdo_mysql >> "%PHP_INI%"
    )
)

REM Enable mysqli
findstr /C:";extension=mysqli" "%PHP_INI%" >nul 2>&1
if %errorlevel%==0 (
    echo Enabling mysqli...
    powershell -Command "(gc '%PHP_INI%') -replace ';extension=mysqli', 'extension=mysqli' | Out-File -encoding ASCII '%PHP_INI%'"
) else (
    findstr /C:"extension=mysqli" "%PHP_INI%" >nul 2>&1
    if %errorlevel%==0 (
        echo mysqli is already enabled
    ) else (
        echo Adding mysqli extension...
        echo extension=mysqli >> "%PHP_INI%"
    )
)

echo.
echo ✓ MySQL extensions configured!
echo.
echo IMPORTANT: Please close ALL terminal windows and open a new one for changes to take effect.
echo.
pause
