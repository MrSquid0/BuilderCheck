package com.example.demo.controller

import com.example.demo.model.*
import com.example.demo.repo.UserRepository
import com.example.demo.security.LoginResponse
import com.example.demo.service.AuthService
import com.example.demo.service.UserService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/user")
class UserController(
	private val userRepository: UserRepository,
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
	fun loginUser(@RequestBody loginRequest: LoginRequest): ResponseEntity<LoginResponse> {
		return ResponseEntity.ok(authService.login(loginRequest))
	}

	@GetMapping("/{id}")
	fun getUser(@PathVariable id: Long): User {
		return userService.getUser(id)
	}

	@PutMapping("/update")
	fun updateUser(@RequestBody user: User): User {
		return userService.updateUser(user)
	}

	@PostMapping("/check-password")
	fun checkPassword(@RequestBody request: PasswordCheckRequest): ResponseEntity<Boolean> {
		return ResponseEntity.ok(userService.checkPassword(request))
	}

	@PutMapping("/update-password")
	fun updatePassword(@RequestBody request: UpdatePasswordRequest): ResponseEntity<User> {
		return ResponseEntity.ok(userService.updatePassword(request))
	}

	@DeleteMapping("/delete-user")
	fun deleteUser(@RequestBody request: DeleteUserRequest): ResponseEntity<Void> {
		userService.deleteUser(request)
		return ResponseEntity.ok().build()
	}

	@GetMapping("/is-manager/{id}")
	fun isManager(@PathVariable id: Long): ResponseEntity<Boolean> {
		return ResponseEntity.ok(userService.isManager(id))
	}

	@GetMapping("/get-user-id/{email}")
	fun getUserIdByEmail(@PathVariable email: String): ResponseEntity<Int> {
		return ResponseEntity.ok(userService.getUserIdByEmail(email))
	}

	@GetMapping("/{idUser}/email")
	fun getUserEmail(@PathVariable idUser: Long): ResponseEntity<String> {
		val user = userService.getUserById(idUser)
		return ResponseEntity.ok(user.email)
	}
}