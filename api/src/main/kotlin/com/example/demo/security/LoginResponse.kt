package com.example.demo.security

data class LoginResponse(
    val token: String,
    val userId: Long,
    val role: String,
    val email: String
)