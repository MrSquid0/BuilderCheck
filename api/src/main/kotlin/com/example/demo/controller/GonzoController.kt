package com.example.demo.controller

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class GonzoController {

	@GetMapping("/gonzo/hello")
	fun getHello(): String {
		return "hello"
	}

	@GetMapping("/gonzo/hola")
	fun getHola(): String {
		return "olaso"
	}
}
