<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->onDelete('cascade');
            $table->enum('type', ['sale', 'purchase', 'expense', 'receipt', 'payment', 'saleReturn', 'purchaseReturn']);
            $table->date('date');
            $table->string('reference_no');
            $table->unsignedInteger('party_id')->nullable();
            $table->string('cash_bank_account')->nullable();
            $table->decimal('total_amount', 15, 2)->default(0);
            $table->boolean('is_posted')->default(true);
            $table->unsignedInteger('created_by_user_id')->nullable();
            $table->timestamps();
            $table->softDeletes();
            
            $table->index('company_id');
            $table->index('type');
            $table->index('date');
            $table->index('reference_no');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
