package com.example.demo.service

import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate

@Service
class NotificationService {

    private val firebaseServerKey = "YOUR_FIREBASE_SERVER_KEY"

    fun sendNotification(to: String, title: String, body: String) {
        val headers = HttpHeaders()
        headers.set("Content-Type", MediaType.APPLICATION_JSON_VALUE)
        headers.set("Authorization", "key=$firebaseServerKey")

        val notification = mapOf("to" to to, "notification" to mapOf("title" to title, "body" to body))
        val request = HttpEntity(notification, headers)

        val restTemplate = RestTemplate()
        restTemplate.postForObject("https://fcm.googleapis.com/fcm/send", request, String::class.java)
    }
}