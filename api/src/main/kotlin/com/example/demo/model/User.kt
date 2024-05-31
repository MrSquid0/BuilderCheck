package com.example.demo.model

import jakarta.persistence.*

@Entity
data class User(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,
    val role: String = "",
    var name: String = "",
    var surname: String = "",
    var email: String = "",
    var password: String = "",
    var mobile: String = ""
)

data class LoginRequest(
    val email: String,
    val password: String
)

data class PasswordCheckRequest(
    val userId: Long,
    val password: String
)

data class UpdatePasswordRequest(
    val userId: Long,
    val currentPassword: String,
    val newPassword: String
)

data class DeleteUserRequest(
    val userId: Long,
    val password: String
)