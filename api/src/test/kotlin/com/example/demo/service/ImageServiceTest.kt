package com.example.demo.service

import com.example.demo.model.Image
import com.example.demo.model.Task
import com.example.demo.repo.ImageRepository
import com.example.demo.repo.TaskRepository
import org.junit.jupiter.api.Test

import org.mockito.Mockito

class ImageServiceTest {

    val imageRepository = Mockito.mock(ImageRepository::class.java)
    val taskRepository = Mockito.mock(TaskRepository::class.java)

    val imageService = ImageService(
        imageRepository,
        taskRepository,
    )

    @Test
    fun createImage() {
        val mockImage = Image()
        Mockito.`when`(imageRepository.save(Mockito.any(Image::class.java))).thenReturn(mockImage)

        imageService.createImage(image = mockImage)

        Mockito.verify(imageRepository, Mockito.times(1)).save(Mockito.any(Image::class.java))
        Mockito.verify(taskRepository, Mockito.times(0)).save(Mockito.any(Task::class.java))
    }
}