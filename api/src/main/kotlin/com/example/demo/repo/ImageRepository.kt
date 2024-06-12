package com.example.demo.repo

import com.example.demo.model.Image
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface ImageRepository : JpaRepository<Image, Int> {
    fun findByIdTask(idTask: Int): List<Image>
}