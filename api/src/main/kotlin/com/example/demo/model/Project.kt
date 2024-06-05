package com.example.demo.model

import java.time.LocalDate
import jakarta.persistence.*

@Entity
data class Project(
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    val idProject: Int = 0,
    var name: String = "",
    var address: String = "",
    var idOwner: Int = 0,
    var idManager: Int = 0,
    var startDate: LocalDate = LocalDate.now(),
    var endDate: LocalDate = LocalDate.now(),
    var budget_pdf: String = "",
    var active: Boolean = false,
    var done: Boolean = false
)