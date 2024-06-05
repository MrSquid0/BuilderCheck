package com.example.demo.service

import com.example.demo.model.Project
import com.example.demo.repo.ProjectRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service

@Service
class ProjectService @Autowired constructor(
    private val projectRepository: ProjectRepository
) {
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
}