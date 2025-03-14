package com.controller;

import com.model.LoginRequest;
import com.model.register.RegisterRequest;
import com.service.auth.AuthService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

@Slf4j
@RestController
@RequestMapping("/gateway")
public class GatewayController {

    @Value("${auth.service.url}")
    private String authServiceUrl;

    @Value("${users.service.url}")
    private String userServiceUrl;

    @Value("${games.service.url}")
    private String gamesServiceUrl;

    @Value("${cart.service.url}")
    private String cartServiceUrl;

    private final AuthService authService;
    private final RestTemplate restTemplate;

    public GatewayController(AuthService authService, RestTemplate restTemplate) {
        this.authService = authService;
        this.restTemplate = restTemplate;
    }

    @PostMapping("/login")
    public ResponseEntity<String> login(@RequestBody LoginRequest loginRequest) {
        ResponseEntity<String> response = restTemplate.postForEntity(authServiceUrl + "/auth/login", loginRequest, String.class);
        if (response.getStatusCode() == HttpStatus.OK) {
            return ResponseEntity.status(HttpStatus.OK).body(response.getBody());
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Error al hacer login usuario");
        }
    }

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody RegisterRequest registerRequest) {
        ResponseEntity<String> response = restTemplate.postForEntity(authServiceUrl + "/auth/register", registerRequest, String.class);
        if (response.getStatusCode() == HttpStatus.CREATED) {
            return ResponseEntity.status(HttpStatus.CREATED).body("Usuario registrado con éxito");
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Error al registrar usuario");
        }
    }

    @PostMapping("/register-key")
    public ResponseEntity<String> registerKey() {
        ResponseEntity<String> response = restTemplate.postForEntity(authServiceUrl + "/auth/register", null, String.class);
        if (response.getStatusCode() == HttpStatus.CREATED) {
            return ResponseEntity.status(HttpStatus.CREATED).body("Clave registrada con éxito");
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Error al registrar usuario");
        }
    }

    @GetMapping("/users/**")
    public ResponseEntity<?> redirectToMicroserviceUsers(@RequestHeader("Authorization") String token) {
        if (authService.isValid(token)) {
            return redirectRequest(userServiceUrl, token);
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @GetMapping("/games/**")
    public ResponseEntity<?> redirectToMicroserviceGames(@RequestHeader("Authorization") String token) {
        if (authService.isValid(token)) {
            return redirectRequest(gamesServiceUrl, token);
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @GetMapping("/cart/**")
    public ResponseEntity<?> redirectToMicroserviceCart(@RequestHeader("Authorization") String token) {
        if (authService.isValid(token)) {
            return redirectRequest(cartServiceUrl, token);
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    private ResponseEntity<?> redirectRequest(String serviceUrl, String token) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", token);

            HttpEntity<?> request = new HttpEntity<>(headers);

            ResponseEntity<String> response = restTemplate.exchange(serviceUrl, HttpMethod.GET, request, String.class);

            return ResponseEntity.ok(response.getBody());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al redirigir la solicitud: " + e.getMessage());
        }
    }
}