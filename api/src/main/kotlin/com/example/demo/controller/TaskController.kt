package com.example.demo.controller

import com.example.demo.model.Task
import com.example.demo.service.TaskService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

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
}