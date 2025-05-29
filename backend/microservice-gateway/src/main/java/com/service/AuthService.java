package com.service;

import com.model.LoginRequest;
import com.model.register.RegisterUsersRequest;
import com.model.register.RegisterAuthRequest;
import com.util.RegisterRequestMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private static final String AUTH_SERVICE = "microservice-auth";
    private static final String USER_SERVICE = "microservice-users";

    @LoadBalanced
    private final RestTemplate restTemplate;

    public ResponseEntity<String> login(LoginRequest loginRequest) {
        try {
            ResponseEntity<String> response = restTemplate.postForEntity(
                    "http://" + AUTH_SERVICE + "/auth/login",
                    loginRequest,
                    String.class
            );
            return ResponseEntity.status(response.getStatusCode())
                    .headers(response.getHeaders())
                    .body(response.getBody());
        } catch (HttpClientErrorException e) {
            return ResponseEntity.status(e.getStatusCode())
                    .headers(e.getResponseHeaders())
                    .body(e.getResponseBodyAsString());
        } catch (Exception e) {
            log.error("Error during login", e);
            return ResponseEntity.internalServerError()
                    .body("Error en el servidor: " + e.getMessage());
        }
    }

    public ResponseEntity<String> register(RegisterUsersRequest registerRequest) {
        registerRequest.setId(UUID.randomUUID().toString());
        RegisterAuthRequest authRequest = RegisterRequestMapper.INSTANCE.toRegisterAuthRequest(registerRequest);

        try {
            // Llamada auth-service
            ResponseEntity<String> authResponse = restTemplate.postForEntity(
                    "http://" + AUTH_SERVICE + "/auth/register",
                    authRequest,
                    String.class
            );

            // Llamada a user-service
            ResponseEntity<String> userResponse = restTemplate.postForEntity(
                    "http://" + USER_SERVICE + "/users/register",
                    registerRequest,
                    String.class
            );

            if (authResponse.getStatusCode() == HttpStatus.CREATED &&
                    userResponse.getStatusCode() == HttpStatus.CREATED) {
                return ResponseEntity.status(HttpStatus.CREATED)
                        .body("Usuario registrado con éxito");
            } else {
                return ResponseEntity.badRequest()
                        .body("Error al registrar usuario");
            }
        } catch (HttpClientErrorException e) {
            return ResponseEntity.status(e.getStatusCode())
                    .headers(e.getResponseHeaders())
                    .body(e.getResponseBodyAsString());
        } catch (Exception e) {
            log.error("Error during registration", e);
            return ResponseEntity.internalServerError()
                    .body("Error interno del servidor: " + e.getMessage());
        }
    }

    public ResponseEntity<Object> proxyRequest(String serviceName, HttpServletRequest request) {
        try {
            //Me quito 'microservice-' (Todas las urls del controller de cada micro empieza o por /users, /games, /auth)
            String micro = serviceName.substring(13);
            String path = request.getRequestURI().replace("/gateway", "");
            String queryString = request.getQueryString(); // Obtener los parámetros de consulta
            String url = "http://" + serviceName + path;

            // Agregar los parámetros de consulta a la URL si existen
            if (queryString != null && !queryString.isEmpty()) {
                url += "?" + queryString;
            }

            HttpMethod method = HttpMethod.valueOf(request.getMethod());
            HttpHeaders headers = new HttpHeaders();
            Collections.list(request.getHeaderNames())
                    .forEach(headerName -> headers.addAll(headerName,
                            Collections.list(request.getHeaders(headerName))));

            String body = request.getReader().lines().collect(Collectors.joining());

            ResponseEntity<String> response = restTemplate.exchange(
                    url,
                    method,
                    new HttpEntity<>(body.isEmpty() ? null : body, headers),
                    String.class
            );

            return ResponseEntity.status(response.getStatusCode())
                    .headers(response.getHeaders())
                    .body(response.getBody());
        } catch (HttpClientErrorException e) {
            return ResponseEntity.status(e.getStatusCode())
                    .headers(e.getResponseHeaders())
                    .body(e.getResponseBodyAsString());
        } catch (Exception e) {
            log.error("Error during proxy request", e);
            return ResponseEntity.internalServerError()
                    .body("Error en el gateway: " + e.getMessage());
        }
    }


}