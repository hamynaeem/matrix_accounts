<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('invoices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->onDelete('cascade');
            $table->foreignId('transaction_id')->constrained()->onDelete('cascade');
            $table->enum('invoice_type', ['sale', 'purchase']);
            $table->unsignedInteger('party_id');
            $table->date('invoice_date');
            $table->date('due_date')->nullable();
            $table->decimal('grand_total', 15, 2)->default(0);
            $table->string('status', 50)->nullable();
            $table->timestamps();
            $table->softDeletes();
            
            $table->index('company_id');
            $table->index('transaction_id');
            $table->index('party_id');
            $table->index('invoice_date');
            $table->index('invoice_type');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('invoices');
    }
};
