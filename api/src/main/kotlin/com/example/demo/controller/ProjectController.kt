package com.example.demo.controller

import com.example.demo.model.Project
import com.example.demo.service.ProjectService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile
import java.io.File
import org.springframework.core.io.Resource
import org.springframework.core.io.UrlResource
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import java.io.FileNotFoundException

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

	@PutMapping("/edit/{id}")
	fun editProject(@PathVariable id: Int, @RequestBody project: Project): ResponseEntity<String> {
		projectService.editProject(id, project)
		return ResponseEntity("Project $id updated", HttpStatus.OK)
	}

	@DeleteMapping("/delete/{id}")
	fun deleteProject(@PathVariable id: Int): ResponseEntity<String> {
		projectService.deleteProject(id)
		return ResponseEntity("Project $id deleted", HttpStatus.OK)
	}

	@PostMapping("/{idProject}/uploadBudgetPdf")
	fun uploadBudgetPdf(@PathVariable idProject: Int, @RequestParam("file") file: MultipartFile) {
		projectService.uploadBudgetPdf(idProject, file)
	}

	@PutMapping("/{idProject}/updateBudgetStatus")
	fun updateBudgetRequested(@PathVariable idProject: Int, @RequestBody budgetStatus: String): ResponseEntity<String> {
		projectService.updateBudgetStatus(idProject, budgetStatus)
		return ResponseEntity("Project $idProject budget requested updated", HttpStatus.OK)
	}

	@DeleteMapping("/{idProject}/deleteBudget")
	fun deleteBudget(@PathVariable idProject: Int): ResponseEntity<String> {
		projectService.deleteBudget(idProject)
		return ResponseEntity("Budget for project $idProject deleted", HttpStatus.OK)
	}

	@GetMapping("/{idProject}/budgetStatus")
	fun getBudgetStatus(@PathVariable idProject: Int): ResponseEntity<String> {
		return ResponseEntity.ok(projectService.getBudgetStatus(idProject))
	}

	@GetMapping("/{idProject}/budgetPdf")
	fun getBudgetPdf(@PathVariable idProject: Int): ResponseEntity<Resource> {
		val project = projectService.getProjectById(idProject)
		val file = File("budgets/${project.budget_pdf}")
		if (!file.exists()) {
			throw FileNotFoundException("File ${project.budget_pdf} not found.")
		}
		val resource: Resource = UrlResource(file.toURI())
		return ResponseEntity.ok()
			.header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"${file.name}\"")
			.contentType(MediaType.parseMediaType("application/pdf"))
			.body(resource)
	}

	@PutMapping("/{idProject}/updateDoneStatus")
	fun updateProjectDoneStatus(@PathVariable idProject: Int, @RequestBody doneStatus: Boolean): ResponseEntity<String> {
		projectService.updateProjectDoneStatus(idProject, doneStatus)
		return ResponseEntity("Project $idProject done status updated", HttpStatus.OK)
	}

	@GetMapping("/{idProject}/doneStatus")
	fun getProjectDoneStatus(@PathVariable idProject: Int): ResponseEntity<Boolean> {
		val doneStatus = projectService.getProjectDoneStatus(idProject)
		return ResponseEntity.ok(doneStatus)
	}
}