<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PaymentOut extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'company_id',
        'voucher_no',
        'voucher_date',
        'party_id',
        'total_amount',
        'description',
        'attachment_path',
        'created_by_user_id',
    ];

    protected $casts = [
        'voucher_date' => 'date',
        'total_amount' => 'decimal:2',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class);
    }

    public function party()
    {
        return $this->belongsTo(Party::class);
    }

    public function lines()
    {
        return $this->hasMany(PaymentOutLine::class);
    }
}
