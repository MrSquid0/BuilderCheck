package com.example.demo.service

import com.example.demo.model.Task
import com.example.demo.repo.ProjectRepository
import com.example.demo.repo.TaskRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.web.multipart.MultipartFile
import java.io.FileNotFoundException
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.sql.Timestamp
import java.time.Instant

@Service
class TaskService{
    @Autowired
    private lateinit var projectRepository: ProjectRepository

    @Autowired
    private lateinit var taskRepository: TaskRepository

    fun createTask(task: Task): Task {
        val project = projectRepository.findById(task.idProject).orElseThrow {
            IllegalArgumentException("Invalid Project ID.") }

        val currentTimestamp = Timestamp.from(Instant.now())
        task.timestamp = currentTimestamp

        if (project.first_task_timestamp == null) {

            project.first_task_timestamp = currentTimestamp
            project.budget_status = "disabled"
            project.budget_pdf = ""
            projectRepository.save(project)
        }

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

    fun deleteTask(task: Task) { //Method for cascade delete
        taskRepository.deleteById(task.idTask)
    }

    fun getTaskById(id: Int): Task {
        return taskRepository.findById(id).orElseThrow { IllegalArgumentException("Task with id $id not found") }
    }

    fun updateTaskStatus(idTask: Int, status: String): Task {
        val task = taskRepository.findById(idTask).orElseThrow { IllegalArgumentException("Invalid Task ID.") }
        task.status = status
        return taskRepository.save(task)
    }

    fun getTaskStatus(idTask: Int): String {
        val task = taskRepository.findById(idTask).orElseThrow { IllegalArgumentException("Invalid Task ID.") }
        return task.status
    }

    fun uploadTaskImage(idTask: Int, image: MultipartFile): Task {
        val task = taskRepository.findById(idTask).orElseThrow { IllegalArgumentException("Invalid Task ID.") }
        val imagePath = "images/${image.originalFilename}"
        val path = Paths.get(imagePath)
        Files.write(path, image.bytes)
        task.image = imagePath
        return taskRepository.save(task)
    }

    fun getTaskImage(idTask: Int): Path {
        val task = taskRepository.findById(idTask).orElseThrow { IllegalArgumentException("Invalid Task ID.") }
        val imagePath = Paths.get(task.image)
        if (!Files.exists(imagePath)) {
            throw FileNotFoundException("File not found at path: $imagePath")
        }
        return imagePath
    }
}