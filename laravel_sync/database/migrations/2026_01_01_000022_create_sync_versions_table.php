<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sync_versions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->onDelete('cascade');
            $table->unsignedBigInteger('current_version')->default(0);
            $table->timestamps();
            
            $table->unique('company_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sync_versions');
    }
};
