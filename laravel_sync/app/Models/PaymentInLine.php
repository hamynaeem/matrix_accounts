<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PaymentInLine extends Model
{
    use HasFactory;

    protected $fillable = [
        'payment_in_id',
        'payment_account_id',
        'amount',
        'reference_no',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
    ];

    public function paymentIn()
    {
        return $this->belongsTo(PaymentIn::class);
    }

    public function paymentAccount()
    {
        return $this->belongsTo(PaymentAccount::class);
    }
}
