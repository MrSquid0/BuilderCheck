package com.example.demo.repo

import com.example.demo.model.User
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query

interface UserRepository : JpaRepository<User, Long> {
	fun findByEmail(email: String): User?
	fun findByMobile(mobile: String): User?
}