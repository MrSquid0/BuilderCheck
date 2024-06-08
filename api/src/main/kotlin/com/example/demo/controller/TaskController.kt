package com.example.demo.controller

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
        val updatedTask = taskService.uploadTaskImage(idTask, image)
        return ResponseEntity.ok(updatedTask)
    }

    @GetMapping("/{idTask}/getImageFile", produces = [MediaType.IMAGE_JPEG_VALUE])
    fun getTaskImage(@PathVariable idTask: Int): ResponseEntity<Resource> {
        val imagePath = taskService.getTaskImage(idTask)
        val resource = UrlResource(imagePath.toUri())
        return ResponseEntity.ok().contentType(MediaType.IMAGE_JPEG).body(resource)
    }

    @GetMapping("/{idTask}/isImageEmpty")
    fun isTaskImageEmpty(@PathVariable idTask: Int): ResponseEntity<Boolean> {
        val isImageEmpty = taskService.isTaskImageEmpty(idTask)
        return ResponseEntity.ok(isImageEmpty)
    }

    @GetMapping("/{idTask}/imageUrl")
    fun getTaskImageUrl(@PathVariable idTask: Int): ResponseEntity<String> {
        val imageUrl = taskService.getTaskImageUrl(idTask)
        return ResponseEntity.ok(imageUrl)
    }

    @DeleteMapping("/{idTask}/deleteImage")
    fun deleteTaskImage(@PathVariable idTask: Int): ResponseEntity<Task> {
        val updatedTask = taskService.deleteTaskImage(idTask)
        return ResponseEntity.ok(updatedTask)
    }
}