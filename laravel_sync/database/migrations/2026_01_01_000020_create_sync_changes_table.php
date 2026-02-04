<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sync_changes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('device_id');
            $table->string('table_name', 100);
            $table->unsignedBigInteger('record_id');
            $table->enum('operation', ['INSERT', 'UPDATE', 'DELETE']);
            $table->json('data');
            $table->unsignedBigInteger('version');
            $table->timestamp('created_at')->useCurrent();
            
            $table->index(['company_id', 'version']);
            $table->index(['table_name', 'record_id']);
            $table->index(['device_id', 'created_at']);
            $table->index('version');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sync_changes');
    }
};
