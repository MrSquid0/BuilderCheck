package com.example.demo.model

import jakarta.persistence.*
import java.sql.Timestamp
import java.time.ZoneId
import java.time.ZonedDateTime

@Entity
data class Image(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val idImage: Int = 0,
    var idTask: Int = 0,
    var imagePath: String = "",
    val timestamp: ZonedDateTime = ZonedDateTime.now(ZoneId.of("Europe/Madrid"))
)