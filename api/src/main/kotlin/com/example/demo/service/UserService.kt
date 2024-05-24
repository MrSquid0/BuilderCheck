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
		// Validación de los datos de entrada
		if (user.email.isEmpty() || user.password.isEmpty() || user.role.isEmpty() || user.name.isEmpty() || user.surname.isEmpty()){
			throw IllegalArgumentException("All values must not be empty")
		}
		if (!user.email.contains("@")) {
			throw IllegalArgumentException("Email must be valid")
		}
		if (user.password.length < 8) {
			throw IllegalArgumentException("Password must be at least 8 characters long")
		}

		// Verificar si el correo electrónico ya está en uso
		if (userRepository.findByEmail(user.email) != null) {
			throw IllegalArgumentException("Email is already in use")
		}

		// Encriptar la contraseña
		user.password = passwordEncoder.encode(user.password)

		// Guardar el usuario en la base de datos
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