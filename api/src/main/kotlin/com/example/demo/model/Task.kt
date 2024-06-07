package com.example.demo.model

import jakarta.persistence.*
import java.sql.Timestamp

@Entity
data class Task(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val idTask: Int = 0,
    var idProject: Int = 0,
    var name: String = "",
    var description: String = "",
    var priority: String = "",
    var image: String = "",
    var status: String = "",
    var timestamp: Timestamp? = null,
)