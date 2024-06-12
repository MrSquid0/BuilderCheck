package com.example.demo.service

import com.example.demo.model.Project
import com.example.demo.repo.ProjectRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.web.multipart.MultipartFile
import org.springframework.context.annotation.Lazy
import java.io.IOException
import java.nio.file.Files
import java.nio.file.Paths
import java.sql.Timestamp
import java.time.Instant
import java.time.ZoneId
import java.time.ZonedDateTime

@Service
class ProjectService{
    @Autowired
    private lateinit var projectRepository: ProjectRepository

    @Autowired
    private lateinit var taskService: TaskService

    @Autowired
    @Lazy
    private lateinit var userService: UserService

    @Autowired
    private lateinit var notificationService: NotificationService


    fun createProject(project: Project): Project {
        return projectRepository.save(project)
    }

    fun getProjectById(idProject: Int): Project {
        return projectRepository.findByIdProject(idProject) ?: throw IllegalArgumentException("Invalid Project ID.")
    }

    fun getProjectsByOwner(idOwner: Int): List<Project> {
        return projectRepository.findByIdOwner(idOwner)
    }

    fun getProjectsByManager(idManager: Int): List<Project> {
        return projectRepository.findByIdManager(idManager)
    }

    fun editProject(id: Int, project: Project): Project {
        val existingProject = projectRepository.findById(id).orElseThrow { IllegalArgumentException("Project with id $id not found") }
        existingProject.name = project.name
        existingProject.address = project.address
        existingProject.idManager = project.idManager
        existingProject.startDate = project.startDate
        existingProject.endDate = project.endDate
        // Add more fields here if needed
        return projectRepository.save(existingProject)
    }

    fun deleteProject(id: Int) {
        val project = projectRepository.findById(id).orElseThrow { IllegalArgumentException("Project with id $id not found") }

        // Get all tasks associated with the project
        val tasks = taskService.getTasksByProjectId(project.idProject)

        // Delete all tasks and their associated images
        tasks.forEach { task ->
            // Delete the task from the database
            taskService.deleteTask(task.idTask)
        }

        // Delete the project directory from the file system
        val projectDirPath = Paths.get("imagesTask/project-${project.idProject}")
        Files.deleteIfExists(projectDirPath)

        // Delete the budget file associated with the project
        val filePath = Paths.get("budgets", project.budget_pdf).toAbsolutePath()
        try {
            Files.deleteIfExists(filePath)
        } catch (e: IOException) {
            println("An error occurred while deleting the budget PDF: ${e.message}")
            e.printStackTrace()
        }

        // Delete the project
        projectRepository.delete(project)
    }

    fun uploadBudgetPdf(idProject: Int, file: MultipartFile) {
        try {
            val project = projectRepository.findByIdProject(idProject)
                ?: throw IllegalArgumentException("Invalid Project ID.")

            // Create the "budgets" directory if it doesn't exist
            val dir = Paths.get("budgets").toAbsolutePath()
            if (!Files.exists(dir)) {
                Files.createDirectories(dir)
            }

            // Save it to the "budgets" directory
            val filePath = dir.resolve("budget_${idProject}.pdf").toAbsolutePath()
            file.transferTo(filePath.toFile())

            // Update the 'budget_pdf' field in the database
            project.budget_pdf = "budget_${idProject}.pdf"
            projectRepository.save(project)
        } catch (e: Exception) {
            // Manejar la excepción
            println("An error occurred while uploading the budget PDF: ${e.message}")
            e.printStackTrace()
        }
    }

    fun updateBudgetStatus(idProject: Int, budgetStatus: String) {
        val project = projectRepository.findByIdProject(idProject) ?:
        throw IllegalArgumentException("Invalid Project ID.")

        val currentTimestamp = Timestamp.from(ZonedDateTime.now(ZoneId.of("Europe/Madrid")).toInstant())

        // If budget is confirmed, set all tasks to "to-do" if their timestamp
        // is before the current timestamp and their status is "disabled"
        if (budgetStatus == "confirmed") {
            val tasks = taskService.getTasksByProjectId(idProject)
            tasks.forEach { task ->
                task.timestamp?.let {
                    if (it.before(currentTimestamp) && task.status == "disabled") {
                        task.status = "to-do"
                        taskService.editTask(task.idTask, task)
                    }
                }
            }

            project.first_task_timestamp = null
        }

        project.budget_status = budgetStatus
        projectRepository.save(project)
    }

    fun deleteBudget(idProject: Int) {
        val project = projectRepository.findByIdProject(idProject)
            ?: throw IllegalArgumentException("Invalid Project ID.")

        // Delete the file from the "budgets" directory
        val filePath = Paths.get("budgets", "budget_${idProject}.pdf").toAbsolutePath()
        try {
            Files.deleteIfExists(filePath)
        } catch (e: IOException) {
            println("An error occurred while deleting the budget PDF: ${e.message}")
            e.printStackTrace()
        }

        // Update the 'budget_pdf', 'budget_confirmed' and 'budget_requested' fields in the database
        project.budget_pdf = ""
        project.budget_status = "disabled"
        projectRepository.save(project)
    }

    fun getBudgetStatus(idProject: Int): String {
        val project = projectRepository.findByIdProject(idProject)
            ?: throw IllegalArgumentException("Invalid Project ID.")
        return project.budget_status
    }

    fun updateProjectDoneStatus(idProject: Int, doneStatus: Boolean): Project {
        val project = projectRepository.findByIdProject(idProject)
            ?: throw IllegalArgumentException("Invalid Project ID.")
        project.done = doneStatus
        return projectRepository.save(project)
    }

    fun getProjectDoneStatus(idProject: Int): Boolean {
        val project = projectRepository.findByIdProject(idProject)
            ?: throw IllegalArgumentException("Invalid Project ID.")
        return project.done
    }

    fun requestBudget(idProject: Int) {
        val project = projectRepository.findByIdProject(idProject)
            ?: throw IllegalArgumentException("Invalid Project ID.")
        val managerDeviceToken = userService.getDeviceToken(project.idManager.toLong())
        notificationService.sendNotification(managerDeviceToken, "Budget Requested", "The owner has requested a budget.")
    }

    fun sendBudget(idProject: Int) {
        val project = projectRepository.findByIdProject(idProject)
            ?: throw IllegalArgumentException("Invalid Project ID.")
        val ownerDeviceToken = userService.getDeviceToken(project.idOwner.toLong())
        notificationService.sendNotification(ownerDeviceToken, "Budget Sent", "The manager has sent the budget.")
    }

    fun acceptBudget(idProject: Int) {
        val project = projectRepository.findByIdProject(idProject)
            ?: throw IllegalArgumentException("Invalid Project ID.")
        project.budget_status = "accepted"
        projectRepository.save(project)
        val managerDeviceToken = userService.getDeviceToken(project.idManager.toLong())
        notificationService.sendNotification(managerDeviceToken, "Budget Accepted", "The owner has accepted the budget.")
    }

    fun rejectBudget(idProject: Int) {
        val project = projectRepository.findByIdProject(idProject)
            ?: throw IllegalArgumentException("Invalid Project ID.")
        project.budget_status = "rejected"
        projectRepository.save(project)
        val managerDeviceToken = userService.getDeviceToken(project.idManager.toLong())
        notificationService.sendNotification(managerDeviceToken, "Budget Rejected", "The owner has rejected the budget.")
    }

    fun changeTaskStatus(idTask: Int, status: String) {
        val task = taskService.getTaskById(idTask)
        task.status = status
        taskService.editTask(idTask, task)
        val project = projectRepository.findByIdProject(task.idProject)
            ?: throw IllegalArgumentException("Invalid Project ID.")
        val ownerDeviceToken = userService.getDeviceToken(project.idOwner.toLong())
        notificationService.sendNotification(ownerDeviceToken, "Task Status Changed",
            "The manager has changed the status of the task ${task.name}.")
    }

    fun finishProject(idProject: Int) {
        val project = projectRepository.findByIdProject(idProject)
            ?: throw IllegalArgumentException("Invalid Project ID.")
        project.done = true
        projectRepository.save(project)
        val managerDeviceToken = userService.getDeviceToken(project.idManager.toLong())
        notificationService.sendNotification(managerDeviceToken, "Project Finished", "The owner has finished the project.")
    }
}