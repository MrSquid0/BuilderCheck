package com.example.demo.service

import com.example.demo.model.Task
import com.example.demo.repo.TaskRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service

@Service
class TaskService @Autowired constructor(
    private val taskRepository: TaskRepository
) {
    fun createTask(task: Task): Task {
        return taskRepository.save(task)
    }

    fun getTasksByProjectId(idProject: Int): List<Task> {
        return taskRepository.findByIdProject(idProject)
    }

    fun editTask(id: Int, task: Task): Task {
        val existingTask = taskRepository.findById(id).orElseThrow { IllegalArgumentException("Task with id $id not found") }
        existingTask.name = task.name
        existingTask.description = task.description
        existingTask.priority = task.priority
        existingTask.image = task.image
        // Add more fields here if needed
        return taskRepository.save(existingTask)
    }

    fun deleteTask(id: Int) {
        val task = taskRepository.findById(id).orElseThrow { IllegalArgumentException("Task with id $id not found") }
        taskRepository.delete(task)
    }

    fun getTaskById(id: Int): Task {
        return taskRepository.findById(id).orElseThrow { IllegalArgumentException("Task with id $id not found") }
    }
}