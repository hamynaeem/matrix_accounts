<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Invoice extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'company_id',
        'transaction_id',
        'invoice_type',
        'party_id',
        'invoice_date',
        'due_date',
        'grand_total',
        'status',
    ];

    protected $casts = [
        'invoice_date' => 'date',
        'due_date' => 'date',
        'grand_total' => 'decimal:2',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function transaction()
    {
        return $this->belongsTo(Transaction::class);
    }

    public function party()
    {
        return $this->belongsTo(Party::class);
    }
}
