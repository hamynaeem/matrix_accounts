<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('stock_ledgers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->onDelete('cascade');
            $table->unsignedInteger('product_id');
            $table->date('date');
            $table->enum('movement_type', ['inPurchase', 'outSale', 'inAdjustment', 'outAdjustment']);
            $table->decimal('quantity_delta', 15, 3)->default(0);
            $table->decimal('unit_cost', 15, 2)->default(0);
            $table->decimal('total_cost', 15, 2)->default(0);
            $table->unsignedInteger('transaction_id')->nullable();
            $table->unsignedInteger('invoice_id')->nullable();
            $table->timestamps();
            
            $table->index('company_id');
            $table->index('product_id');
            $table->index('date');
            $table->index('movement_type');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stock_ledgers');
    }
};
