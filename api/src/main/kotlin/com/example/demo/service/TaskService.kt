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
}