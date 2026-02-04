<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SyncChange extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'company_id',
        'user_id',
        'device_id',
        'table_name',
        'record_id',
        'operation',
        'data',
        'version',
    ];

    protected $casts = [
        'data' => 'array',
        'record_id' => 'integer',
        'version' => 'integer',
        'created_at' => 'datetime',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
