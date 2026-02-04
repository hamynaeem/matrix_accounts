<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\SyncService;
use Illuminate\Http\Request;

class SyncController extends Controller
{
    protected $syncService;

    public function __construct(SyncService $syncService)
    {
        $this->syncService = $syncService;
    }

    /**
     * Pull changes from server
     * 
     * POST /api/sync/pull
     * {
     *   "company_id": 1,
     *   "device_id": "uuid-abc123",
     *   "last_version": 42,
     *   "tables": ["parties", "products"]
     * }
     */
    public function pull(Request $request)
    {
        $request->validate([
            'company_id' => 'required|integer',
            'device_id' => 'required|string',
            'last_version' => 'required|integer',
            'tables' => 'nullable|array',
        ]);

        // Verify user has access to this company
        $hasAccess = $request->user()->companies()
            ->where('companies.id', $request->company_id)
            ->exists();

        if (!$hasAccess) {
            return response()->json([
                'success' => false,
                'message' => 'You do not have access to this company',
            ], 403);
        }

        $result = $this->syncService->pullChanges(
            $request->company_id,
            $request->device_id,
            $request->last_version,
            $request->tables
        );

        return response()->json($result);
    }

    /**
     * Push changes to server
     * 
     * POST /api/sync/push
     * {
     *   "company_id": 1,
     *   "device_id": "uuid-abc123",
     *   "changes": [
     *     {
     *       "table": "parties",
     *       "local_id": "temp_001",
     *       "operation": "INSERT",
     *       "data": {...},
     *       "timestamp": "2026-01-12T12:00:00Z"
     *     }
     *   ]
     * }
     */
    public function push(Request $request)
    {
        $request->validate([
            'company_id' => 'required|integer',
            'device_id' => 'required|string',
            'changes' => 'required|array',
        ]);

        // Verify user has access to this company
        $hasAccess = $request->user()->companies()
            ->where('companies.id', $request->company_id)
            ->exists();

        if (!$hasAccess) {
            return response()->json([
                'success' => false,
                'message' => 'You do not have access to this company',
            ], 403);
        }

        $result = $this->syncService->pushChanges(
            $request->company_id,
            $request->user()->id,
            $request->device_id,
            $request->changes
        );

        return response()->json($result);
    }

    /**
     * Get sync status for device
     * 
     * GET /api/sync/status?company_id=1&device_id=uuid-abc123
     */
    public function status(Request $request)
    {
        $request->validate([
            'company_id' => 'required|integer',
            'device_id' => 'required|string',
        ]);

        // Verify user has access to this company
        $hasAccess = $request->user()->companies()
            ->where('companies.id', $request->company_id)
            ->exists();

        if (!$hasAccess) {
            return response()->json([
                'success' => false,
                'message' => 'You do not have access to this company',
            ], 403);
        }

        $status = $this->syncService->getSyncStatus(
            $request->company_id,
            $request->device_id
        );

        return response()->json([
            'success' => true,
            'status' => $status,
        ]);
    }
}
