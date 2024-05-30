package com.example.demo.model

import jakarta.persistence.*

@Entity
data class User(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,
    val role: String = "",
    val name: String = "",
    val surname: String = "",
    val email: String = "",
    var password: String = "",
    var mobile: String = ""
)

data class LoginRequest(
    val email: String,
    val password: String
)