package com.example.demo.controller

import com.example.demo.model.LoginRequest
import com.example.demo.model.User
import com.example.demo.repo.UserRepository
import com.example.demo.service.UserService
import org.springframework.web.bind.annotation.*
import javax.sql.DataSource

@CrossOrigin(origins = ["http://localhost:8080"])
@RestController
@RequestMapping("/api/user")
class UserController(
	private val userRepository: UserRepository,
	private val dataSource: DataSource,
	private val userService: UserService
) {

	@GetMapping("/count")
	fun getUserCount(): Long {
		return userRepository.count()
	}

	@GetMapping("/all")
	fun getAllUsers(): List<User> {
		return userRepository.findAll()
	}

	@GetMapping("/dburl")
	fun getDatabaseUrl(): String {
		val connection = dataSource.connection
		val url = connection.metaData.url
		connection.close()
		return url
	}

	@PostMapping("/register")
	fun registerUser(@RequestBody user: User): User {
		return userService.register(user)
	}

	@PostMapping("/login")
	fun loginUser(@RequestBody loginRequest: LoginRequest): User {
		return userService.login(loginRequest)
	}
}