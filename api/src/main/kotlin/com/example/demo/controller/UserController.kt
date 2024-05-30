package com.example.demo.controller

import com.example.demo.model.LoginRequest
import com.example.demo.model.User
import com.example.demo.repo.UserRepository
import com.example.demo.service.AuthService
import com.example.demo.service.UserService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import javax.sql.DataSource

@RestController
@RequestMapping("/user")
class UserController(
	private val userRepository: UserRepository,
	private val dataSource: DataSource,
	private val userService: UserService,
	private val authService: AuthService
) {

	@GetMapping("/count")
	fun getUserCount(): Long {
		return userRepository.count()
	}

	@GetMapping("/all")
	fun getAllUsers(): List<User> {
		return userRepository.findAll()
	}

	@GetMapping("/emailExists/{email}")
	fun emailExists(@PathVariable email: String): Boolean {
		return userService.emailExists(email)
	}

	@GetMapping("/mobileExists/{mobile}")
	fun mobileExists(@PathVariable mobile: String): Boolean {
		return userService.mobileExists(mobile)
	}

	@PostMapping("/register")
	fun registerUser(@RequestBody user: User): User {
		return userService.register(user)
	}

	@PostMapping("/login")
	fun loginUser(@RequestBody loginRequest: LoginRequest): ResponseEntity<Any> {
		userService.login(loginRequest)
		return authService.login(loginRequest)
	}
}