<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('device_sync_status', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->onDelete('cascade');
            $table->string('device_id');
            $table->string('device_name')->nullable();
            $table->unsignedBigInteger('last_sync_version')->default(0);
            $table->timestamp('last_sync_at')->nullable();
            $table->timestamps();
            
            $table->unique(['company_id', 'device_id']);
            $table->index('last_sync_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('device_sync_status');
    }
};
