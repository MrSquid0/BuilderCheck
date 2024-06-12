package com.example.demo.service

import com.example.demo.model.Task
import com.example.demo.repo.ProjectRepository
import com.example.demo.repo.TaskRepository
import com.example.demo.model.Image
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.dao.EmptyResultDataAccessException
import org.springframework.stereotype.Service
import org.springframework.web.multipart.MultipartFile
import java.io.FileNotFoundException
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.sql.Timestamp
import java.time.Instant
import java.time.ZoneId
import java.time.ZonedDateTime
import java.util.UUID

@Service
class TaskService{
    @Autowired
    private lateinit var projectRepository: ProjectRepository

    @Autowired
    private lateinit var taskRepository: TaskRepository

    @Autowired
    private lateinit var imageService: ImageService

    fun createTask(task: Task): Task {
        val project = projectRepository.findById(task.idProject).orElseThrow {
            IllegalArgumentException("Invalid Project ID.") }

        val currentTimestamp = Timestamp.from(ZonedDateTime.now(ZoneId.of("Europe/Madrid")).toInstant())
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

        // Get all images associated with the task
        val images = imageService.getImagesByTaskId(task.idTask)

        // Delete each image file from the file system and from the database
        images.forEach { image ->
            // Delete the image file from the file system
            val dirPath = Paths.get("imagesTask/project-${task.idProject}/task-${task.idTask}")
            val imagePath = Paths.get("$dirPath/${image.imagePath}")
            Files.deleteIfExists(imagePath)

            // Delete the image from the database
            imageService.deleteImage(image.idImage)
        }

        // Delete the task directory from the file system
        val taskDirPath = Paths.get("imagesTask/project-${task.idProject}/task-${task.idTask}")
        Files.deleteIfExists(taskDirPath)

        // Delete the task from the database
        taskRepository.delete(task)
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

    fun uploadTaskImage(idTask: Int, image: MultipartFile): Image {
        val task = taskRepository.findById(idTask).orElseThrow { IllegalArgumentException("Invalid Task ID.") }

        // Create the directories if they do not exist
        val dirPath = Paths.get("imagesTask/project-${task.idProject}/task-${task.idTask}")
        if (!Files.exists(dirPath)) {
            Files.createDirectories(dirPath)
        }

        // Save the image with a unique name
        val imageName = "task-${UUID.randomUUID()}.${getFileExtension(image.originalFilename)}"

        val imagePath = "$dirPath/$imageName"
        val path = Paths.get(imagePath)
        Files.write(path, image.bytes)

        val newImage = Image(idTask = idTask, imagePath = imageName, timestamp = ZonedDateTime.now(ZoneId.of("Europe/Madrid")))
        return imageService.createImage(newImage)
    }

    fun getTaskImages(idTask: Int): List<Image> {
        return imageService.getImagesByTaskId(idTask)
    }

    fun isTaskImageEmpty(idTask: Int): Boolean {
        val task = taskRepository.findById(idTask).orElseThrow { IllegalArgumentException("Invalid Task ID.") }
        val images = imageService.getImagesByTaskId(task.idTask)
        return images.isEmpty()
    }

    fun deleteTaskImage(idImage: Int) {
        val image = imageService.getImageById(idImage)
        val task = taskRepository.findById(image.idTask).orElseThrow { IllegalArgumentException("Invalid Task ID.") }

        // Delete the image file from the file system
        val dirPath = Paths.get("imagesTask/project-${task.idProject}/task-${task.idTask}")
        val imagePath = Paths.get("$dirPath/${image.imagePath}")
        Files.deleteIfExists(imagePath)

        // Check if the project directory is empty, and if so, delete it
        Files.newDirectoryStream(dirPath).use { dirStream ->
            if (!dirStream.iterator().hasNext()) { // The directory is empty
                Files.deleteIfExists(dirPath)
            }
        }

        // Delete the image from the database
        imageService.deleteImage(idImage)
    }

    fun areThereTasks(idProject: Int): Boolean {
        try {
            return getTasksByProjectId(idProject).isNotEmpty()
        } catch (ex: EmptyResultDataAccessException) {
            throw IllegalArgumentException("Invalid Project ID.")
        }
    }
}