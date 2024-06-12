package com.example.demo.service

import com.example.demo.model.Image
import com.example.demo.repo.ImageRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service

@Service
class ImageService {
    @Autowired
    private lateinit var imageRepository: ImageRepository

    fun createImage(image: Image): Image {
        return imageRepository.save(image)
    }

    fun getImagesByTaskId(idTask: Int): List<Image> {
        return imageRepository.findByIdTask(idTask)
    }

    fun deleteImage(idImage: Int) {
        imageRepository.deleteById(idImage)
    }

    fun getImageById(idImage: Int): Image {
        return imageRepository.findById(idImage).orElseThrow { IllegalArgumentException("Invalid Image ID.") }
    }
}