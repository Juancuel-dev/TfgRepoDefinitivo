package com.service;

import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;
import reactor.core.publisher.Mono;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.scheduler.Schedulers;
import com.model.LoginRequest;
import com.model.register.RegisterUsersRequest;
import com.util.RegisterRequestMapper;
import com.model.User;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    // Nombres de los servicios registrados en Eureka (en lugar de URLs)
    private static final String AUTH_SERVICE = "auth-service"; // Nombre en Eureka
    private static final String USER_SERVICE = "user-service";
    private static final String GAME_SERVICE = "game-service";
    private static final String CART_SERVICE = "cart-service";

    // Usa RestTemplate con balanceo de carga
    private final RestTemplate restTemplate;

    // === Métodos de autenticación ===
    public Mono<ResponseEntity<String>> login(LoginRequest loginRequest) {
        return Mono.fromCallable(() -> {
            try {
                ResponseEntity<String> response = restTemplate.postForEntity(
                        "http://" + AUTH_SERVICE + "/login", // Usa el nombre de Eureka
                        loginRequest,
                        String.class
                );

                return ResponseEntity.status(response.getStatusCode()).body(response.getBody());
            } catch (HttpClientErrorException e) {
                return ResponseEntity.status(e.getStatusCode()).body(e.getResponseBodyAsString());
            } catch (Exception e) {
                return ResponseEntity.internalServerError()
                        .body("Error en el servidor: " + e.getMessage());
            }
        }).subscribeOn(Schedulers.boundedElastic());
    }

    public Mono<ResponseEntity<String>> register(RegisterUsersRequest register) {
        return Mono.fromCallable(() -> {
            register.setId(UUID.randomUUID().toString());
            try {
                // Llama a auth-service usando Eureka
                ResponseEntity<String> responseAuth = restTemplate.postForEntity(
                        "http://" + AUTH_SERVICE + "/register",
                        RegisterRequestMapper.INSTANCE.toRegisterAuthRequest(register),
                        String.class
                );

                // Llama a user-service usando Eureka
                ResponseEntity<String> responseUsers = restTemplate.postForEntity(
                        "http://" + USER_SERVICE + "/register",
                        register,
                        String.class
                );

                if (responseAuth.getStatusCode() == HttpStatus.CREATED &&
                        responseUsers.getStatusCode() == HttpStatus.CREATED) {
                    return ResponseEntity.status(HttpStatus.CREATED)
                            .body("Usuario registrado con éxito");
                } else {
                    return ResponseEntity.badRequest().body("Error al registrar usuario");
                }
            } catch (HttpClientErrorException e) {
                return ResponseEntity.status(e.getStatusCode()).body(e.getResponseBodyAsString());
            } catch (Exception e) {
                return ResponseEntity.internalServerError()
                        .body("Error interno del servidor: " + e.getMessage());
            }
        }).subscribeOn(Schedulers.boundedElastic());
    }

    // === Métodos de proxy (simplificados con Eureka) ===
    public Mono<ResponseEntity<?>> proxyRequest(String serviceName, ServerWebExchange exchange) {
        return Mono.fromCallable(() -> {
            try {
                String path = exchange.getRequest().getPath().toString()
                        .replace("/gateway", "");
                String method = exchange.getRequest().getMethod().name();
                String query = exchange.getRequest().getURI().getQuery();
                String targetUrl = "http://" + serviceName + path + (query != null ? "?" + query : "");

                HttpHeaders headers = new HttpHeaders();
                exchange.getRequest().getHeaders().forEach(headers::addAll);

                String body = exchange.getAttributeOrDefault("cachedRequestBody", "");

                ResponseEntity<?> response = restTemplate.exchange(
                        targetUrl,
                        HttpMethod.valueOf(method),
                        new HttpEntity<>(body.isEmpty() ? null : body, headers),
                        Object.class
                );

                return ResponseEntity.status(response.getStatusCode())
                        .headers(response.getHeaders())
                        .body(response.getBody());
            } catch (HttpClientErrorException e) {
                return ResponseEntity.status(e.getStatusCode()).body(e.getResponseBodyAsString());
            } catch (Exception e) {
                return ResponseEntity.internalServerError()
                        .body("Error en el gateway: " + e.getMessage());
            }
        }).subscribeOn(Schedulers.boundedElastic());
    }

    public Mono<ResponseEntity<?>> proxyUsersRequest(ServerWebExchange exchange) {
        return proxyRequest(USER_SERVICE, exchange);
    }

    public Mono<ResponseEntity<?>> proxyGamesRequest(ServerWebExchange exchange) {
        return proxyRequest(GAME_SERVICE, exchange);
    }

    public Mono<ResponseEntity<?>> proxyCartRequest(ServerWebExchange exchange) {
        return proxyRequest(CART_SERVICE, exchange);
    }

    public Mono<ResponseEntity<?>> myself(String token) {
        return Mono.fromCallable(() -> {
            try {
                HttpHeaders headers = new HttpHeaders();
                headers.set("Authorization", token);

                ResponseEntity<User> response = restTemplate.exchange(
                        "http://" + USER_SERVICE + "/me",
                        HttpMethod.GET,
                        new HttpEntity<>(headers),
                        User.class
                );

                return ResponseEntity.status(response.getStatusCode()).body(response.getBody());
            } catch (Exception e) {
                return ResponseEntity.internalServerError()
                        .body("Error al obtener información del usuario");
            }
        }).subscribeOn(Schedulers.boundedElastic());
    }
}