<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Company extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'subscriber_id',
        'name',
        'primary_currency',
        'financial_year_start_month',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'financial_year_start_month' => 'integer',
    ];

    public function users()
    {
        return $this->belongsToMany(User::class, 'company_user')
            ->withPivot('role', 'user_group_id', 'is_active')
            ->withTimestamps();
    }

    public function parties()
    {
        return $this->hasMany(Party::class);
    }

    public function products()
    {
        return $this->hasMany(Product::class);
    }

    public function accounts()
    {
        return $this->hasMany(Account::class);
    }

    public function invoices()
    {
        return $this->hasMany(Invoice::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function syncVersion()
    {
        return $this->hasOne(SyncVersion::class);
    }
}
