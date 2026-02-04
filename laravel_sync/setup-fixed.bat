@echo off
echo ========================================
echo Matrix Accounts - Laravel Setup Script
echo ========================================
echo.

cd /d "%~dp0"

echo [1/8] Checking Laravel installation...
if not exist "vendor" (
    echo Installing Laravel dependencies...
    composer require laravel/framework:^11.0
    composer require laravel/sanctum:^4.0
    composer require guzzlehttp/guzzle:^7.8
    echo.
) else (
    echo Laravel dependencies already installed
    echo.
)

echo [2/8] Checking for artisan file...
if not exist "artisan" (
    echo Creating artisan file...
    (
        echo ^<?php
        echo.
        echo define('LARAVEL_START', microtime(true^)^);
        echo.
        echo require __DIR__.'/vendor/autoload.php';
        echo.
        echo $app = require_once __DIR__.'/bootstrap/app.php';
        echo.
        echo $kernel = $app-^>make(Illuminate\Contracts\Console\Kernel::class^);
        echo.
        echo $status = $kernel-^>handle(
        echo     $input = new Symfony\Component\Console\Input\ArgvInput,
        echo     new Symfony\Component\Console\Output\ConsoleOutput
        echo ^);
        echo.
        echo $kernel-^>terminate($input, $status^);
        echo.
        echo exit($status^);
    ) > artisan
    echo.
)

echo [3/8] Creating bootstrap directory...
if not exist "bootstrap" mkdir bootstrap
if not exist "bootstrap\cache" mkdir bootstrap\cache

if not exist "bootstrap\app.php" (
    echo Creating bootstrap/app.php...
    (
        echo ^<?php
        echo.
        echo use Illuminate\Foundation\Application;
        echo use Illuminate\Foundation\Configuration\Exceptions;
        echo use Illuminate\Foundation\Configuration\Middleware;
        echo.
        echo return Application::configure(basePath: dirname(__DIR__^)^)
        echo     -^>withRouting(
        echo         api: __DIR__.'/../routes/api.php',
        echo         commands: __DIR__.'/../routes/console.php',
        echo         health: '/up',
        echo     ^)
        echo     -^>withMiddleware(function (Middleware $middleware^) {
        echo         //
        echo     }^)
        echo     -^>withExceptions(function (Exceptions $exceptions^) {
        echo         //
        echo     }^)-^>create(^);
    ) > bootstrap\app.php
)

echo [4/8] Creating additional directories...
if not exist "storage" mkdir storage
if not exist "storage\app" mkdir storage\app
if not exist "storage\app\public" mkdir storage\app\public
if not exist "storage\framework" mkdir storage\framework
if not exist "storage\framework\cache" mkdir storage\framework\cache
if not exist "storage\framework\cache\data" mkdir storage\framework\cache\data
if not exist "storage\framework\sessions" mkdir storage\framework\sessions
if not exist "storage\framework\testing" mkdir storage\framework\testing
if not exist "storage\framework\views" mkdir storage\framework\views
if not exist "storage\logs" mkdir storage\logs

if not exist "config" mkdir config
if not exist "resources" mkdir resources
if not exist "public" mkdir public
if not exist "tests" mkdir tests

echo [5/8] Setting up environment file...
if not exist ".env" (
    if exist ".env.example" (
        copy .env.example .env
        echo .env file created
    ) else (
        echo .env.example not found, please create .env manually
    )
) else (
    echo .env file already exists
)
echo.

echo [6/8] Running composer install...
composer install
echo.

echo [7/8] Generating application key...
php artisan key:generate
echo.

echo [8/8] Publishing Sanctum configuration...
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo IMPORTANT: Configure your database in .env:
echo   DB_DATABASE=matrix_accounts_sync
echo   DB_USERNAME=root
echo   DB_PASSWORD=your_password
echo.
echo Then run:
echo   1. Create database in MySQL
echo   2. php artisan migrate
echo   3. php artisan serve
echo.
echo ========================================
pause
