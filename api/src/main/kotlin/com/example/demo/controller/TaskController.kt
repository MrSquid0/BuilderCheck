package com.example.demo.controller

import com.example.demo.model.Image
import com.example.demo.model.Task
import com.example.demo.service.TaskService
import org.springframework.core.io.UrlResource
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile
import org.springframework.core.io.Resource

@RestController
@RequestMapping("/task")
class TaskController(
    private val taskService: TaskService
) {

    @PostMapping("/create")
    fun createTask(@RequestBody task: Task): ResponseEntity<Task> {
        return ResponseEntity.ok(taskService.createTask(task))
    }

    @GetMapping("/project/{idProject}")
    fun getTasksByProjectId(@PathVariable idProject: Int): ResponseEntity<List<Task>> {
        return ResponseEntity.ok(taskService.getTasksByProjectId(idProject))
    }

    @PutMapping("/edit/{id}")
    fun editTask(@PathVariable id: Int, @RequestBody task: Task): ResponseEntity<String> {
        taskService.editTask(id, task)
        return ResponseEntity("Task updated", HttpStatus.OK)
    }

    @DeleteMapping("/delete/{id}")
    fun deleteTask(@PathVariable id: Int): ResponseEntity<String> {
        taskService.deleteTask(id)
        return ResponseEntity("Task deleted", HttpStatus.OK)
    }

    @GetMapping("/{id}")
    fun getTaskById(@PathVariable id: Int): ResponseEntity<Task> {
        return ResponseEntity.ok(taskService.getTaskById(id))
    }

    @PutMapping("/{idTask}/status")
    fun updateTaskStatus(@PathVariable idTask: Int, @RequestBody status: String): ResponseEntity<Task> {
        val updatedTask = taskService.updateTaskStatus(idTask, status)
        return ResponseEntity.ok(updatedTask)
    }

    @GetMapping("/{idTask}/getStatus")
    fun getTaskStatus(@PathVariable idTask: Int): ResponseEntity<String> {
        val taskStatus = taskService.getTaskStatus(idTask)
        return ResponseEntity.ok(taskStatus)
    }

    @PostMapping("/{idTask}/uploadImageFile")
    fun uploadTaskImage(@PathVariable idTask: Int, @RequestParam("image") image: MultipartFile): ResponseEntity<Task> {
        taskService.uploadTaskImage(idTask, image)
        val task = taskService.getTaskById(idTask)
        return ResponseEntity.ok(task)
    }

    @GetMapping("/{idTask}/getImages")
    fun getTaskImages(@PathVariable idTask: Int): ResponseEntity<List<Image>> {
        val images = taskService.getTaskImages(idTask)
        return ResponseEntity.ok(images)
    }

    @GetMapping("/{idTask}/isImageEmpty")
    fun isTaskImageEmpty(@PathVariable idTask: Int): ResponseEntity<Boolean> {
        val isImageEmpty = taskService.isTaskImageEmpty(idTask)
        return ResponseEntity.ok(isImageEmpty)
    }

    @DeleteMapping("/deleteImage/{idImage}")
    fun deleteTaskImage(@PathVariable idImage: Int): ResponseEntity<String> {
        taskService.deleteTaskImage(idImage)
        return ResponseEntity("Image deleted", HttpStatus.OK)
    }

    @GetMapping("/project/{idProject}/areThereTasks")
    fun areThereTasks(@PathVariable idProject: Int): ResponseEntity<Any> {
        return try {
            val areThereTasks = taskService.areThereTasks(idProject)
            ResponseEntity.ok(areThereTasks)
        } catch (ex: IllegalArgumentException) {
            ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ex.message)
        }
    }
}