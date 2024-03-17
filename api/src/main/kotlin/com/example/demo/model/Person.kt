package com.example.demo.model

import com.fasterxml.jackson.annotation.JsonFormat
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.validation.constraints.Min
import java.time.LocalDate

@Entity
class Person(
        @field:Id
        @field:Min(0)
        var id: Long? = null,
        var name: String? = null,
        var birthdate: LocalDate = LocalDate.now(),
)