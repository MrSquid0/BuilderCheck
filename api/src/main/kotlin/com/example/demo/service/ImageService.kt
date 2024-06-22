package com.example.demo.service

import com.example.demo.model.Image
import com.example.demo.repo.ImageRepository
import com.example.demo.repo.TaskRepository
import org.springframework.stereotype.Service
import java.io.FileNotFoundException
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths

@Service
class ImageService(
    private var imageRepository: ImageRepository,
    private var taskRepository: TaskRepository,
) {

    fun createImage(image: Image): Image {
        return imageRepository.save(image)
    }

    fun getImagesByTaskId(idTask: Int): List<Image> {
        return imageRepository.findByIdTask(idTask)
    }

    fun deleteImage(idImage: Int) {
        imageRepository.deleteById(idImage)
    }

    fun getImageFilePath(image: Image): Path {
        val task = taskRepository.findById(image.idTask).orElseThrow { IllegalArgumentException("Invalid Task ID.") }
        val dirPath = Paths.get("imagesTask/project-${task.idProject}/task-${task.idTask}")
        return Paths.get("$dirPath/${image.imagePath}")
    }

    fun getImageById(id: Int): Image {
        val image = imageRepository.findById(id).orElseThrow { IllegalArgumentException("Image with id $id not found") }
        val imagePath = getImageFilePath(image)
        if (!Files.exists(imagePath)) {
            throw FileNotFoundException("File ${imagePath} not found.")
        }
        return image
    }
}