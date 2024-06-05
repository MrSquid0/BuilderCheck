package com.example.demo.repo

import com.example.demo.model.Project
import org.springframework.data.jpa.repository.JpaRepository

interface ProjectRepository : JpaRepository<Project, Int> {
    fun findByIdProject(idProject: Int): Project?
    fun findByIdOwner(idOwner: Int): List<Project>
    fun findByIdManager(idManager: Int): List<Project>
}