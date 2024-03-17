package com.example.demo.service

import com.example.demo.model.Person
import com.example.demo.repo.PersonRepository
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.stereotype.Controller
import org.springframework.stereotype.Service
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Service
class PersonService(
		val personRepository: PersonRepository,
) {

	fun createPerson(person: Person): Person {
		return personRepository.save(person)
	}

	fun findPerson(id: Long): Person {
		return personRepository.findById(id).get()
	}
}
