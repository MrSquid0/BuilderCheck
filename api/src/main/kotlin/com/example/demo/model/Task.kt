package com.example.demo.model

import jakarta.persistence.*

@Entity
data class Task(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val idTask: Int = 0,
    var idProject: Int = 0,
    var name: String = "",
    var description: String = "",
    var priority: String = "",
    var image: String = "",
    var status: String = ""
)