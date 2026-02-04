<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DeviceSyncStatus extends Model
{
    use HasFactory;

    protected $table = 'device_sync_status';

    protected $fillable = [
        'company_id',
        'device_id',
        'device_name',
        'last_sync_version',
        'last_sync_at',
    ];

    protected $casts = [
        'last_sync_version' => 'integer',
        'last_sync_at' => 'datetime',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }
}
