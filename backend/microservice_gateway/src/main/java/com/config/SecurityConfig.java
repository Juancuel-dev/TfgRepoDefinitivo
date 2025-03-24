package com.config;

import com.service.JwtService;
import io.jsonwebtoken.security.Keys;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableReactiveMethodSecurity;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.SecurityWebFiltersOrder;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.oauth2.jwt.NimbusReactiveJwtDecoder;
import org.springframework.security.oauth2.jwt.ReactiveJwtDecoder;
import org.springframework.security.web.server.SecurityWebFilterChain;
import org.springframework.security.web.server.context.NoOpServerSecurityContextRepository;
import org.springframework.web.client.RestTemplate;

import java.util.Base64;

@Configuration
@EnableWebFluxSecurity
@EnableReactiveMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
        return http
                .csrf(ServerHttpSecurity.CsrfSpec::disable)
                .authorizeExchange(exchanges -> exchanges
                        .pathMatchers("/gateway/login", "/gateway/register").permitAll()
                        .anyExchange().authenticated()
                )
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(jwt -> jwt.jwtDecoder(jwtDecoder()))
                )
                .securityContextRepository(NoOpServerSecurityContextRepository.getInstance())
                .addFilterAt(jwtAuthenticationFilter(jwtService()), SecurityWebFiltersOrder.AUTHENTICATION)
                .build();
    }

    @Bean
    public ReactiveJwtDecoder jwtDecoder() {
        String secretKey = "dGhlIHNhbXBsZSBub3RlIG9mIHRoZSBzdGF0ZW1lbnQgaXMgdGhlIHRydWUgdGhlcnJpY2FsIGtleQ";
        byte[] keyBytes = Base64.getDecoder().decode(secretKey);
        return NimbusReactiveJwtDecoder.withSecretKey(Keys.hmacShaKeyFor(keyBytes)).build();
    }

    @Bean
    @LoadBalanced  // Habilita el balanceo de carga con Eureka
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    @Bean
    public JwtService jwtService() {
        return new JwtService(restTemplate());
    }

    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter(JwtService jwtService) {
        return new JwtAuthenticationFilter(jwtService);
    }
}