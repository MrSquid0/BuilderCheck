package com.example.demo.service

import com.example.demo.model.LoginRequest
import com.example.demo.model.User
import com.example.demo.repo.UserRepository
import com.example.demo.security.LoginResponse
import java.security.SecureRandom
import java.util.Base64
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.SignatureAlgorithm
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service
import org.springframework.web.bind.annotation.*
import java.util.*
import org.springframework.security.crypto.password.PasswordEncoder


fun generateSecretKey(): String {
    val random = SecureRandom()
    val bytes = ByteArray(32) // 256 bits
    random.nextBytes(bytes)
    return Base64.getEncoder().encodeToString(bytes)
}

@Service
class AuthService @Autowired constructor(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder
) {
    private val SECRET_KEY = generateSecretKey()

    fun generateToken(user: User): String {
        return Jwts.builder()
            .setSubject(user.email)
            .setIssuedAt(Date())
            .setExpiration(Date(System.currentTimeMillis() + 3600000)) // 1 hour
            .signWith(SignatureAlgorithm.HS256, SECRET_KEY.toByteArray())
            .compact()
    }

    fun login(loginRequest: LoginRequest): LoginResponse {
        val user = userRepository.findByEmail(loginRequest.email)
        if (user != null && passwordEncoder.matches(loginRequest.password, user.password)) {
            val token = generateToken(user)
            return LoginResponse(token, user.id.toLong())
        } else {
            throw IllegalArgumentException("Invalid email or password.")
        }
    }
}