package com.example.demo.repo

import com.example.demo.model.Task
import org.springframework.data.jpa.repository.JpaRepository

interface TaskRepository : JpaRepository<Task, Int> {
    fun findByIdProject(idProject: Int): List<Task>
}