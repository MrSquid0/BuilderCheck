package com.example.demo.service

import com.example.demo.model.LoginRequest
import java.security.SecureRandom
import java.util.Base64
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.SignatureAlgorithm
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service
import org.springframework.web.bind.annotation.*
import java.util.*

fun generateSecretKey(): String {
    val random = SecureRandom()
    val bytes = ByteArray(32) // 256 bits
    random.nextBytes(bytes)
    return Base64.getEncoder().encodeToString(bytes)
}

@Service
class AuthService {
    private val SECRET_KEY = generateSecretKey()
    fun login(@RequestBody loginRequest: LoginRequest): ResponseEntity<Any> {
        val token = Jwts.builder()
            .setSubject(loginRequest.email)
            .setIssuedAt(Date())
            .setExpiration(Date(System.currentTimeMillis() + 3600000)) // 1 hora
            .signWith(SignatureAlgorithm.HS256, SECRET_KEY.toByteArray())
            .compact()

        return ResponseEntity.ok(AuthResponse(token))
    }
}

data class AuthResponse(val token: String)
