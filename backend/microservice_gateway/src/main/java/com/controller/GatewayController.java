package com.controller;

import com.model.LoginRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

@RestController
@RequestMapping("/gateway")
public class GatewayController {

    @Value("${auth.service.url}") // URL del Auth Service
    private String authServiceUrl;

    @Value("${users.service.url}") // URL del Microservicio users
    private String userServiceUrl;

    @Value("${games.service.url}") // URL del Microservicio games
    private String gamesServiceUrl;

    @Value("${cart.service.url}") // URL del Microservicio cart
    private String cartServiceUrl;

    private final RestTemplate restTemplate;

    public GatewayController(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
        restTemplate.getMessageConverters().add(new MappingJackson2HttpMessageConverter());

    }

    // Maneja el login
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        try {
            String url = authServiceUrl + "/auth/login";

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<LoginRequest> request = new HttpEntity<>(loginRequest, headers);

            ResponseEntity<?> response = restTemplate.exchange(url, HttpMethod.POST, request, ResponseEntity.class);

            return ResponseEntity.ok(response.getBody());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Error durante el login: " + e.getMessage());
        }
    }

    // Redirige las solicitudes al Microservicio 1
    @GetMapping("/users/**")
    public ResponseEntity<?> redirectToMicroserviceUsers(@RequestHeader("Authorization") String token) {
        return redirectRequest(userServiceUrl, token);
    }

    // Redirige las solicitudes al Microservicio 2
    @GetMapping("/games/**")
    public ResponseEntity<?> redirectToMicroserviceGames(@RequestHeader("Authorization") String token) {
        return redirectRequest(gamesServiceUrl, token);
    }

    // Redirige las solicitudes al Microservicio 2
    @GetMapping("/cart/**")
    public ResponseEntity<?> redirectToMicroserviceCart(@RequestHeader("Authorization") String token) {
        return redirectRequest(cartServiceUrl, token);
    }

    // auxiliar para redirigir solicitudes
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