package com.example.demo.config


import com.example.demo.security.CustomFilter
import com.example.demo.security.RestAuthenticationEntryPoint
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.provisioning.InMemoryUserDetailsManager
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter
import org.springframework.security.core.userdetails.User

@Configuration
class CustomWebSecurityConfigurerAdapter(
    val authenticationEntryPoint: RestAuthenticationEntryPoint,
)  {

    @Bean
    fun userDetailsService(): InMemoryUserDetailsManager {
        val user = User.builder()
            .username("user1")
            .password(passwordEncoder().encode("user1Pass"))
            .roles("ADMIN")
            .build()
        return InMemoryUserDetailsManager(user)
    }

    @Bean
    @Throws(Exception::class)
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        http.csrf().disable().authorizeHttpRequests { expressionInterceptUrlRegistry ->
            expressionInterceptUrlRegistry
                .requestMatchers("/public/**")
                .permitAll()
                .requestMatchers("/swagger-ui/**")
                .permitAll()
                .requestMatchers("/v3/api-docs/**")
                .permitAll()
                .anyRequest()
                .authenticated()
        }
            .httpBasic { httpSecurityHttpBasicConfigurer ->
                httpSecurityHttpBasicConfigurer.authenticationEntryPoint(
                    authenticationEntryPoint
                )
            }
        http.addFilterAfter(CustomFilter(), BasicAuthenticationFilter::class.java)
        return http.build()
    }

    @Bean
    fun passwordEncoder(): PasswordEncoder {
        return BCryptPasswordEncoder()
    }
}