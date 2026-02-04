<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('account_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->onDelete('cascade');
            $table->unsignedInteger('account_id');
            $table->enum('transaction_type', ['saleInvoice', 'paymentIn', 'purchaseInvoice', 'paymentOut', 'journalEntry', 'saleReturn', 'purchaseReturn', 'expense']);
            $table->unsignedInteger('reference_id');
            $table->date('transaction_date');
            $table->decimal('debit', 15, 2)->default(0);
            $table->decimal('credit', 15, 2)->default(0);
            $table->decimal('running_balance', 15, 2)->default(0);
            $table->text('description')->nullable();
            $table->string('reference_no')->nullable();
            $table->unsignedInteger('party_id')->nullable();
            $table->timestamps();
            
            $table->index('company_id');
            $table->index('account_id');
            $table->index('transaction_type');
            $table->index('reference_id');
            $table->index('transaction_date');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('account_transactions');
    }
};
