package com.example.demo.repo

import com.example.demo.model.Person
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface PersonRepository  : JpaRepository<Person, Long>{

    fun findPersonByName(name: String)

}