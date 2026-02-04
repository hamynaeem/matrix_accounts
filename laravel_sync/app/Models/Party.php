<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Party extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'company_id',
        'name',
        'party_type',
        'customer_class',
        'phone',
        'email',
        'address',
        'opening_balance',
        'credit_limit',
        'payment_terms_days',
        'is_active',
    ];

    protected $casts = [
        'opening_balance' => 'decimal:2',
        'credit_limit' => 'decimal:2',
        'payment_terms_days' => 'integer',
        'is_active' => 'boolean',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function invoices()
    {
        return $this->hasMany(Invoice::class);
    }

    public function paymentsIn()
    {
        return $this->hasMany(PaymentIn::class);
    }

    public function paymentsOut()
    {
        return $this->hasMany(PaymentOut::class);
    }

    protected static function boot()
    {
        parent::boot();

        static::created(function ($party) {
            app(\App\Services\SyncService::class)->recordChange(
                $party->company_id,
                auth()->id(),
                request()->header('X-Device-Id'),
                'parties',
                $party->id,
                'INSERT',
                $party->toArray()
            );
        });

        static::updated(function ($party) {
            app(\App\Services\SyncService::class)->recordChange(
                $party->company_id,
                auth()->id(),
                request()->header('X-Device-Id'),
                'parties',
                $party->id,
                'UPDATE',
                $party->toArray()
            );
        });

        static::deleted(function ($party) {
            app(\App\Services\SyncService::class)->recordChange(
                $party->company_id,
                auth()->id(),
                request()->header('X-Device-Id'),
                'parties',
                $party->id,
                'DELETE',
                ['id' => $party->id]
            );
        });
    }
}
