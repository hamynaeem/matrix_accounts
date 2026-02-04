@echo off
echo ============================================
echo Matrix Accounts Sync - Complete Setup
echo ============================================
echo.

set MYSQL_BIN=G:\PHPMySQL\mysql\bin\mysql.exe

REM Prompt for MySQL password
set /p MYSQL_PASS="Enter your MySQL root password: "

echo.
echo Creating database...
"%MYSQL_BIN%" -u root -p%MYSQL_PASS% -e "CREATE DATABASE IF NOT EXISTS matrix_accounts_sync CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

if %errorlevel%==0 (
    echo ✓ Database created successfully!
    echo.
    
    REM Update .env file
    echo Updating .env file with password...
    powershell -Command "(gc .env) -replace 'DB_PASSWORD=.*', 'DB_PASSWORD=%MYSQL_PASS%' | Out-File -encoding ASCII .env"
    
    echo.
    echo ============================================
    echo Testing database connection...
    echo ============================================
    php artisan db:show
    
    if %errorlevel%==0 (
        echo.
        echo ✓ Connection successful!
        echo.
        set /p RUN_MIG="Run migrations now? (y/n): "
        
        if /i "%RUN_MIG%"=="y" (
            echo.
            echo Running migrations...
            php artisan migrate
            
            if %errorlevel%==0 (
                echo.
                echo ============================================
                echo ✓ Setup Complete!
                echo ============================================
                echo.
                echo Next steps:
                echo 1. Start server: php artisan serve
                echo 2. Test API: curl http://localhost:8000/api/health
                echo.
                
                set /p START_SERVER="Start server now? (y/n): "
                if /i "%START_SERVER%"=="y" (
                    echo.
                    echo Starting Laravel server...
                    echo Server will run at: http://localhost:8000
                    echo Press Ctrl+C to stop
                    echo.
                    php artisan serve
                )
            )
        )
    )
) else (
    echo.
    echo ✗ Failed to create database. Please check:
    echo - MySQL root password is correct
    echo - MySQL server is running
    echo.
)

pause
