package com.example.demo.service

import com.example.demo.model.*
import com.example.demo.repo.UserRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service

@Service
class UserService @Autowired constructor(
	private val userRepository: UserRepository,
	private val passwordEncoder: PasswordEncoder
){
	fun register(user: User): User {
		if (user.email.isEmpty() || user.password.isEmpty() || user.role.isEmpty()
			|| user.name.isEmpty() || user.surname.isEmpty() || user.mobile.isEmpty()){
			throw IllegalArgumentException("All values must not be empty")
		}

		if (user.password.length < 8) {
			throw IllegalArgumentException("Password must be at least 8 characters long")
		}

		// Verify if the current mail is already in use
		if (userRepository.findByEmail(user.email) != null) {
			throw IllegalArgumentException("Email is already in use")
		}

		//Email validation
		val emailRegex = "^[A-Za-z](.*)([@]{1})(.{1,})(\\.)(.{1,})".toRegex()
		if (!emailRegex.matches(user.email)) {
			throw IllegalArgumentException("Email must be valid")
		}

		//Phone validation
		val mobileRegex = "^\\+(?:[0-9] ?){6,14}[0-9]$".toRegex()
		if (!mobileRegex.matches(user.mobile)) {
			throw IllegalArgumentException("Mobile number must be valid")
		}

		//Password validation (8 chars min, 1 uppercase, 1 lowercase, 1 number)
		val passwordRegex = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=\\S+$).{8,}$".toRegex()
		if (!passwordRegex.matches(user.password)) {
			throw IllegalArgumentException("Password must be at least 8 characters long, " +
					"contain at least one uppercase letter, one lowercase letter and " +
					"one number.")
		}

		// Encrypt the password
		user.password = passwordEncoder.encode(user.password)

		// Save the user into the database
		return userRepository.save(user)
	}

	fun emailExists(email: String): Boolean {
		return userRepository.findByEmail(email) != null
	}

	fun mobileExists(mobile: String): Boolean {
		return userRepository.findByMobile(mobile) != null
	}

	fun getUser(id: Long): User {
		return userRepository.findById(id).orElseThrow { IllegalArgumentException("Invalid user ID") }
	}

	fun updateUser(user: User): User {
		val existingUser = userRepository.findById(user.id.toLong()).orElseThrow { IllegalArgumentException("Invalid user ID") }
		existingUser.name = user.name
		existingUser.surname = user.surname
		existingUser.email = user.email
		existingUser.mobile = user.mobile
		return userRepository.save(existingUser)
	}

	fun checkPassword(request: PasswordCheckRequest): Boolean {
		val user = userRepository.findById(request.userId).orElseThrow { IllegalArgumentException("Invalid user ID") }
		return passwordEncoder.matches(request.password, user.password)
	}

	fun updatePassword(request: UpdatePasswordRequest): User {
		val user = userRepository.findById(request.userId).orElseThrow { IllegalArgumentException("Invalid user ID") }

		if (!passwordEncoder.matches(request.currentPassword, user.password)) {
			throw IllegalArgumentException("Current password is incorrect")
		}

		val passwordRegex = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=\\S+$).{8,}$".toRegex()
		if (!passwordRegex.matches(request.newPassword)) {
			throw IllegalArgumentException("New password must be at least 8 characters long, " +
					"contain at least one uppercase letter, one lowercase letter and " +
					"one number.")
		}

		user.password = passwordEncoder.encode(request.newPassword)
		return userRepository.save(user)
	}

	fun deleteUser(request: DeleteUserRequest) {
		val user = userRepository.findById(request.userId).orElseThrow { IllegalArgumentException("Invalid user ID") }

		if (!passwordEncoder.matches(request.password, user.password)) {
			throw IllegalArgumentException("Password is incorrect")
		}

		userRepository.delete(user)
	}
}