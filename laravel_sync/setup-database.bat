@echo off
echo ============================================
echo Matrix Accounts Sync - Database Setup
echo ============================================
echo.

REM Test MySQL connection
echo Testing MySQL connection...
php artisan db:show 2>nul

if %errorlevel%==0 (
    echo.
    echo ✓ MySQL connection successful!
    echo.
    echo Ready to run migrations? This will create all 22 tables.
    echo.
    set /p CONFIRM="Run migrations now? (y/n): "
    
    if /i "%CONFIRM%"=="y" (
        echo.
        echo Running migrations...
        php artisan migrate
        
        if %errorlevel%==0 (
            echo.
            echo ============================================
            echo ✓ Database setup complete!
            echo ============================================
            echo.
            echo Next steps:
            echo 1. Start the server: php artisan serve
            echo 2. Test the API: curl http://localhost:8000/api/health
            echo 3. Check SETUP_COMPLETE.md for more details
            echo.
        ) else (
            echo.
            echo ✗ Migration failed. Check the error above.
            echo.
            echo Troubleshooting:
            echo - Verify .env database credentials
            echo - Ensure database exists: CREATE DATABASE matrix_accounts_sync;
            echo - Check MySQL is running
            echo.
        )
    )
) else (
    echo.
    echo ✗ Cannot connect to MySQL!
    echo.
    echo Please follow these steps:
    echo.
    echo 1. Install MySQL from: https://dev.mysql.com/downloads/installer/
    echo 2. Create the database:
    echo    mysql -u root -p
    echo    CREATE DATABASE matrix_accounts_sync;
    echo.
    echo 3. Update .env file with your MySQL credentials:
    echo    DB_USERNAME=root
    echo    DB_PASSWORD=your_password
    echo.
    echo 4. Run this script again
    echo.
)

echo.
pause
