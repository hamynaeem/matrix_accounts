<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payment_ins', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->onDelete('cascade');
            $table->string('receipt_no');
            $table->date('receipt_date');
            $table->unsignedInteger('party_id');
            $table->decimal('total_amount', 15, 2)->default(0);
            $table->text('description')->nullable();
            $table->string('attachment_path')->nullable();
            $table->unsignedInteger('created_by_user_id')->nullable();
            $table->timestamps();
            $table->softDeletes();
            
            $table->index('company_id');
            $table->index('party_id');
            $table->index('receipt_date');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payment_ins');
    }
};
