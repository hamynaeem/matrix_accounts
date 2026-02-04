<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\SyncController;
use App\Http\Controllers\Api\PartyController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Health check endpoint
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now()->toIso8601String(),
        'service' => 'Matrix Accounts Sync API',
    ]);
});

// Public routes
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Authentication
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/user', [AuthController::class, 'user']);

    // Sync endpoints
    Route::prefix('sync')->group(function () {
        Route::post('/pull', [SyncController::class, 'pull']);
        Route::post('/push', [SyncController::class, 'push']);
        Route::get('/status', [SyncController::class, 'status']);
    });

    // Data endpoints
    Route::prefix('parties')->group(function () {
        Route::get('/', [PartyController::class, 'index']);
        Route::post('/', [PartyController::class, 'store']);
        Route::put('/{id}', [PartyController::class, 'update']);
        Route::delete('/{id}', [PartyController::class, 'destroy']);
    });

    // Similar routes can be added for:
    // - Products
    // - Invoices
    // - Transactions
    // - Payments
    // - Accounts
});
