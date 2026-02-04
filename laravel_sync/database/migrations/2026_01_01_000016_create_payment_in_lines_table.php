<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payment_in_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('payment_in_id')->constrained()->onDelete('cascade');
            $table->unsignedInteger('payment_account_id');
            $table->decimal('amount', 15, 2)->default(0);
            $table->string('reference_no')->nullable();
            $table->timestamps();
            
            $table->index('payment_in_id');
            $table->index('payment_account_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payment_in_lines');
    }
};
