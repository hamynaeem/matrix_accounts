<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class StockLedger extends Model
{
    use HasFactory;

    protected $fillable = [
        'company_id',
        'product_id',
        'date',
        'movement_type',
        'quantity_delta',
        'unit_cost',
        'total_cost',
        'transaction_id',
        'invoice_id',
    ];

    protected $casts = [
        'date' => 'date',
        'quantity_delta' => 'decimal:3',
        'unit_cost' => 'decimal:2',
        'total_cost' => 'decimal:2',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
