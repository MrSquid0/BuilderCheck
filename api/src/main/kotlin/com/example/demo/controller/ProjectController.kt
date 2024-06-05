package com.example.demo.controller

import com.example.demo.model.Project
import com.example.demo.service.ProjectService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/project")
class ProjectController(
	private val projectService: ProjectService
) {

	@PostMapping("/create")
	fun createProject(@RequestBody project: Project): ResponseEntity<Project> {
		return ResponseEntity.ok(projectService.createProject(project))
	}

	@GetMapping("/owner/{idOwner}")
	fun getProjectsByOwner(@PathVariable idOwner: Int): ResponseEntity<Any> {
		return try {
			ResponseEntity.ok(projectService.getProjectsByOwner(idOwner))
		} catch (e: IllegalArgumentException) {
			ResponseEntity.badRequest().body(e.message)
		}
	}

	@GetMapping("/manager/{idManager}")
	fun getProjectsByManager(@PathVariable idManager: Int): ResponseEntity<Any> {
		return try {
			ResponseEntity.ok(projectService.getProjectsByManager(idManager))
		} catch (e: IllegalArgumentException) {
			ResponseEntity.badRequest().body(e.message)
		}
	}

	@GetMapping("/{idProject}")
	fun getProjectById(@PathVariable idProject: Int): ResponseEntity<Any> {
		return try {
			val project = projectService.getProjectById(idProject)
			ResponseEntity.ok(project)
		} catch (e: IllegalArgumentException) {
			ResponseEntity.badRequest().body(e.message)
		}
	}
}