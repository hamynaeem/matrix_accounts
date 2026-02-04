<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SyncVersion extends Model
{
    use HasFactory;

    protected $fillable = [
        'company_id',
        'current_version',
    ];

    protected $casts = [
        'current_version' => 'integer',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }
}
