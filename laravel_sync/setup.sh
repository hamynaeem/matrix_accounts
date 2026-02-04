#!/bin/bash

echo "========================================"
echo "Matrix Accounts - Laravel Setup Script"
echo "========================================"
echo ""

cd laravel_sync

echo "[1/7] Checking if Laravel is installed..."
if [ ! -d "vendor" ]; then
    echo "Laravel not found. Installing Laravel 11..."
    composer create-project laravel/laravel . "11.*" --prefer-dist
    echo ""
else
    echo "Laravel already installed. Running composer install..."
    composer install
    echo ""
fi

echo "[2/7] Setting up environment file..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo ".env file created"
else
    echo ".env file already exists"
fi
echo ""

echo "[3/7] Generating application key..."
php artisan key:generate
echo ""

echo "[4/7] Publishing Sanctum configuration..."
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
echo ""

echo "[5/7] Database setup..."
echo ""
echo "Please configure your database in .env file:"
echo "  DB_DATABASE=matrix_accounts_sync"
echo "  DB_USERNAME=root"
echo "  DB_PASSWORD=your_password"
echo ""
read -p "Press Enter after configuring database..."

echo "[6/7] Running migrations..."
php artisan migrate
echo ""

echo "[7/7] Setup complete!"
echo ""
echo "========================================"
echo "Next Steps:"
echo "========================================"
echo "1. Start server:    php artisan serve"
echo "2. Test API:        See QUICK_START.md"
echo "3. View docs:       See ARCHITECTURE.md"
echo "========================================"
echo ""
