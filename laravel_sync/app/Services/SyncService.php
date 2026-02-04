<?php

namespace App\Services;

use App\Models\SyncChange;
use App\Models\SyncVersion;
use App\Models\DeviceSyncStatus;
use Illuminate\Support\Facades\DB;

class SyncService
{
    /**
     * Record a change in the sync_changes table
     */
    public function recordChange(
        int $companyId,
        ?int $userId,
        ?string $deviceId,
        string $tableName,
        int $recordId,
        string $operation,
        array $data
    ): SyncChange {
        // Get next version number
        $version = $this->getNextVersion($companyId);

        // Create sync change record
        return SyncChange::create([
            'company_id' => $companyId,
            'user_id' => $userId ?? 1, // Default to system user
            'device_id' => $deviceId ?? 'server',
            'table_name' => $tableName,
            'record_id' => $recordId,
            'operation' => $operation,
            'data' => $data,
            'version' => $version,
        ]);
    }

    /**
     * Get the next version number for a company
     */
    protected function getNextVersion(int $companyId): int
    {
        return DB::transaction(function () use ($companyId) {
            $syncVersion = SyncVersion::firstOrCreate(
                ['company_id' => $companyId],
                ['current_version' => 0]
            );

            $syncVersion->increment('current_version');
            $syncVersion->refresh();

            return $syncVersion->current_version;
        });
    }

    /**
     * Pull changes from server (device requesting updates)
     */
    public function pullChanges(
        int $companyId,
        string $deviceId,
        int $lastVersion = 0,
        ?array $tables = null
    ): array {
        $query = SyncChange::where('company_id', $companyId)
            ->where('version', '>', $lastVersion)
            ->where('device_id', '!=', $deviceId) // Don't send back device's own changes
            ->orderBy('version', 'asc');

        if ($tables) {
            $query->whereIn('table_name', $tables);
        }

        $changes = $query->get();

        $currentVersion = $this->getCurrentVersion($companyId);

        // Update device sync status
        $this->updateDeviceSyncStatus($companyId, $deviceId, $currentVersion);

        return [
            'success' => true,
            'current_version' => $currentVersion,
            'changes' => $changes->map(function ($change) {
                return [
                    'version' => $change->version,
                    'table' => $change->table_name,
                    'record_id' => $change->record_id,
                    'operation' => $change->operation,
                    'data' => $change->data,
                    'timestamp' => $change->created_at->toIso8601String(),
                ];
            })->toArray(),
        ];
    }

    /**
     * Push changes from device to server
     */
    public function pushChanges(
        int $companyId,
        int $userId,
        string $deviceId,
        array $changes
    ): array {
        $idMappings = [];
        $conflicts = [];

        DB::transaction(function () use ($companyId, $userId, $deviceId, $changes, &$idMappings, &$conflicts) {
            foreach ($changes as $change) {
                try {
                    $result = $this->applyChange(
                        $companyId,
                        $userId,
                        $deviceId,
                        $change
                    );

                    // Map temporary IDs to server IDs
                    if (isset($change['local_id']) && isset($result['server_id'])) {
                        $idMappings[$change['local_id']] = $result['server_id'];
                    }

                    if (isset($result['conflict'])) {
                        $conflicts[] = $result['conflict'];
                    }
                } catch (\Exception $e) {
                    \Log::error('Error applying change: ' . $e->getMessage(), [
                        'change' => $change,
                        'exception' => $e,
                    ]);
                }
            }
        });

        $currentVersion = $this->getCurrentVersion($companyId);

        return [
            'success' => true,
            'current_version' => $currentVersion,
            'conflicts' => $conflicts,
            'id_mappings' => $idMappings,
        ];
    }

    /**
     * Apply a single change from device
     */
    protected function applyChange(
        int $companyId,
        int $userId,
        string $deviceId,
        array $change
    ): array {
        $tableName = $change['table'];
        $operation = $change['operation'];
        $data = $change['data'];

        // Get the model class
        $modelClass = $this->getModelClass($tableName);
        if (!$modelClass) {
            throw new \Exception("Unknown table: {$tableName}");
        }

        $result = [];

        switch ($operation) {
            case 'INSERT':
                // Remove temporary ID and any auto-increment IDs
                unset($data['id']);
                $data['company_id'] = $companyId;

                $record = $modelClass::create($data);
                $result['server_id'] = $record->id;
                break;

            case 'UPDATE':
                $recordId = $data['id'] ?? $change['record_id'];
                $record = $modelClass::where('company_id', $companyId)
                    ->find($recordId);

                if ($record) {
                    // Check for conflicts (optional - basic timestamp comparison)
                    // For now, use last-write-wins strategy
                    $record->update($data);
                } else {
                    throw new \Exception("Record not found: {$tableName}#{$recordId}");
                }
                break;

            case 'DELETE':
                $recordId = $data['id'] ?? $change['record_id'];
                $record = $modelClass::where('company_id', $companyId)
                    ->find($recordId);

                if ($record) {
                    $record->delete();
                }
                break;
        }

        return $result;
    }

    /**
     * Get model class for table name
     */
    protected function getModelClass(string $tableName): ?string
    {
        $mappings = [
            'parties' => \App\Models\Party::class,
            'products' => \App\Models\Product::class,
            'invoices' => \App\Models\Invoice::class,
            'transactions' => \App\Models\Transaction::class,
            'transaction_lines' => \App\Models\TransactionLine::class,
            'accounts' => \App\Models\Account::class,
            'account_transactions' => \App\Models\AccountTransaction::class,
            'payment_accounts' => \App\Models\PaymentAccount::class,
            'payment_ins' => \App\Models\PaymentIn::class,
            'payment_in_lines' => \App\Models\PaymentInLine::class,
            'payment_outs' => \App\Models\PaymentOut::class,
            'payment_out_lines' => \App\Models\PaymentOutLine::class,
            'stock_ledgers' => \App\Models\StockLedger::class,
            'units_of_measure' => \App\Models\UnitOfMeasure::class,
            'item_categories' => \App\Models\ItemCategory::class,
        ];

        return $mappings[$tableName] ?? null;
    }

    /**
     * Get current version for a company
     */
    public function getCurrentVersion(int $companyId): int
    {
        $syncVersion = SyncVersion::where('company_id', $companyId)->first();
        return $syncVersion ? $syncVersion->current_version : 0;
    }

    /**
     * Update device sync status
     */
    protected function updateDeviceSyncStatus(
        int $companyId,
        string $deviceId,
        int $version
    ): void {
        DeviceSyncStatus::updateOrCreate(
            [
                'company_id' => $companyId,
                'device_id' => $deviceId,
            ],
            [
                'last_sync_version' => $version,
                'last_sync_at' => now(),
            ]
        );
    }

    /**
     * Get sync status for a device
     */
    public function getSyncStatus(int $companyId, string $deviceId): array
    {
        $deviceStatus = DeviceSyncStatus::where('company_id', $companyId)
            ->where('device_id', $deviceId)
            ->first();

        $currentVersion = $this->getCurrentVersion($companyId);

        $pendingChanges = SyncChange::where('company_id', $companyId)
            ->where('version', '>', $deviceStatus?->last_sync_version ?? 0)
            ->where('device_id', '!=', $deviceId)
            ->count();

        return [
            'device_id' => $deviceId,
            'last_sync_version' => $deviceStatus?->last_sync_version ?? 0,
            'current_version' => $currentVersion,
            'pending_changes' => $pendingChanges,
            'last_sync_at' => $deviceStatus?->last_sync_at?->toIso8601String(),
            'is_synced' => $pendingChanges === 0,
        ];
    }
}
