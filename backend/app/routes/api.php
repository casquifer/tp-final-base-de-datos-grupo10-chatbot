<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ChatController;

Route::post('/chat',       [ChatController::class, 'chat']);
Route::post('/chat/close', [ChatController::class, 'close']);   // opcional
Route::post('/chat/escalate', [ChatController::class, 'escalate']); // opcional

