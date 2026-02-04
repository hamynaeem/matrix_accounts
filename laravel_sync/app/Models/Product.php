<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'company_id',
        'sku',
        'name',
        'category_id',
        'uom_id',
        'is_tracked',
        'last_cost',
        'sale_price',
        'opening_qty',
        'is_active',
    ];

    protected $casts = [
        'is_tracked' => 'boolean',
        'last_cost' => 'decimal:2',
        'sale_price' => 'decimal:2',
        'opening_qty' => 'decimal:3',
        'is_active' => 'boolean',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function category()
    {
        return $this->belongsTo(ItemCategory::class, 'category_id');
    }

    public function unitOfMeasure()
    {
        return $this->belongsTo(UnitOfMeasure::class, 'uom_id');
    }

    public function stockLedgers()
    {
        return $this->hasMany(StockLedger::class);
    }

    protected static function boot()
    {
        parent::boot();

        static::created(function ($product) {
            app(\App\Services\SyncService::class)->recordChange(
                $product->company_id,
                auth()->id(),
                request()->header('X-Device-Id'),
                'products',
                $product->id,
                'INSERT',
                $product->toArray()
            );
        });

        static::updated(function ($product) {
            app(\App\Services\SyncService::class)->recordChange(
                $product->company_id,
                auth()->id(),
                request()->header('X-Device-Id'),
                'products',
                $product->id,
                'UPDATE',
                $product->toArray()
            );
        });

        static::deleted(function ($product) {
            app(\App\Services\SyncService::class)->recordChange(
                $product->company_id,
                auth()->id(),
                request()->header('X-Device-Id'),
                'products',
                $product->id,
                'DELETE',
                ['id' => $product->id]
            );
        });
    }
}
