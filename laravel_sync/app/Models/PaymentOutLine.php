<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PaymentOutLine extends Model
{
    use HasFactory;

    protected $fillable = [
        'payment_out_id',
        'payment_account_id',
        'amount',
        'reference_no',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
    ];

    public function paymentOut()
    {
        return $this->belongsTo(PaymentOut::class);
    }

    public function paymentAccount()
    {
        return $this->belongsTo(PaymentAccount::class);
    }
}
