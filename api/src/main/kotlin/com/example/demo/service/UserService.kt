package com.example.demo.service

import com.example.demo.model.User
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
		user.password = passwordEncoder.encode(user.password)
		return userRepository.save(user)
	}

	fun login(email: String, password: String): User? {
		val user = userRepository.findByEmail(email)
		return if (user != null && passwordEncoder.matches(password, user.password)) {
			user
		} else {
			null
		}
	}
}