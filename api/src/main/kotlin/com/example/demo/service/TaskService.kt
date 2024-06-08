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
        return taskRepository.save(existingTask)
    }

    fun deleteTask(id: Int) {
        val task = taskRepository.findById(id).orElseThrow { IllegalArgumentException("Task with id $id not found") }

        // Delete the task image from the file system if it exists
        if (task.image.isNotEmpty()) {
            deleteTaskImage(task.idTask)
        }

        // Delete the task from the database
        taskRepository.delete(task)
    }

    fun deleteTask(task: Task) { //Method for cascade delete
        // Delete the task image from the file system if it exists
        if (task.image.isNotEmpty()) {
            deleteTaskImage(task.idTask)
        }

        // Delete the task from the database
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

    // Helper function to get the file extension
    fun getFileExtension(fileName: String?): String {
        if (fileName == null) {
            return ""
        }

        val dotIndex = fileName.lastIndexOf(".")
        return if (dotIndex >= 0) {
            fileName.substring(dotIndex + 1)
        } else {
            ""
        }
    }

    fun uploadTaskImage(idTask: Int, image: MultipartFile): Task {
        val task = taskRepository.findById(idTask).orElseThrow { IllegalArgumentException("Invalid Task ID.") }

        // Create the directories if they do not exist
        val dirPath = Paths.get("imagesTask/project-${task.idProject}")
        if (!Files.exists(dirPath)) {
            Files.createDirectories(dirPath)
        }

        // Save the image with the task ID as the file name
        val imageName = "task-${task.idTask}.${getFileExtension(image.originalFilename)}"

        val imagePath = "$dirPath/$imageName"
        val path = Paths.get(imagePath)
        Files.write(path, image.bytes)

        task.image = imageName
        return taskRepository.save(task)
    }

    fun getTaskImage(idTask: Int): Path {
        val task = taskRepository.findById(idTask).orElseThrow { IllegalArgumentException("Invalid Task ID.") }

        val dirPath = Paths.get("imagesTask/project-${task.idProject}")
        val imagePath = Paths.get("$dirPath/${task.image}")

        if (!Files.exists(imagePath)) {
            throw FileNotFoundException("File not found at path: $imagePath")
        }
        return imagePath
    }

    fun isTaskImageEmpty(idTask: Int): Boolean {
        val task = taskRepository.findById(idTask).orElseThrow { IllegalArgumentException("Invalid Task ID.") }
        return task.image.isEmpty()
    }

    fun getTaskImageUrl(idTask: Int): String {
        val task = taskRepository.findById(idTask).orElseThrow { IllegalArgumentException("Invalid Task ID.") }
        return "/imagesTask/project-${task.idProject}/${task.image}"
    }

    fun deleteTaskImage(idTask: Int): Task {
        val task = taskRepository.findById(idTask).orElseThrow { IllegalArgumentException("Invalid Task ID.") }

        // Delete the image file from the file system
        val dirPath = Paths.get("imagesTask/project-${task.idProject}")
        val imagePath = Paths.get("$dirPath/${task.image}")
        Files.deleteIfExists(imagePath)

        // Check if the project directory is empty, and if so, delete it
        Files.newDirectoryStream(dirPath).use { dirStream ->
            if (!dirStream.iterator().hasNext()) { // The directory is empty
                Files.deleteIfExists(dirPath)
            }
        }

        // Update the 'image' field in the database
        task.image = ""
        return taskRepository.save(task)
    }
}