package com.example.demo.controller

import com.example.demo.model.Person
import com.example.demo.service.PersonService
import jakarta.validation.Valid
import jakarta.websocket.server.PathParam
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.LocalDate

@RestController
class AlbertoController( 
		val personService: PersonService
) {

	@GetMapping("/alberto/persons/{id}")
	fun getPerson(@PathVariable id: Long): Person {
		return personService.findPerson(id)
	}

	@PostMapping("/alberto/persons")
	fun createPerson(@Valid @RequestBody person: Person): Person {
		return personService.createPerson(person)
	}

	@DeleteMapping("/alberto/persons/{id}")
	fun deletePerson(@PathVariable id: Long): Boolean {
		return true
	}

	@GetMapping("/alberto/hola")
	fun getHola(): String {
		return "olaso"
	}
}
