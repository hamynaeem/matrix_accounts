<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PaymentIn extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'company_id',
        'receipt_no',
        'receipt_date',
        'party_id',
        'total_amount',
        'description',
        'attachment_path',
        'created_by_user_id',
    ];

    protected $casts = [
        'receipt_date' => 'date',
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
        return $this->hasMany(PaymentInLine::class);
    }
}
