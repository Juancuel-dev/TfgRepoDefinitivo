package com.controller;

import com.model.UserDTO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.reactive.result.view.RedirectView;

import java.security.Principal;

@RestController
public class GatewayController {

    @Value("${auth.service.url}") // URL del Auth Service
    private String authServiceUrl;

    private final RestTemplate restTemplate;

    // Inyectar RestTemplate a través del constructor
    public GatewayController(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    // Redirige al login si se accede a la raíz
    @GetMapping("/")
    public RedirectView home() {
        return new RedirectView("/login");
    }

    // Muestra el nombre del usuario autenticado
    @GetMapping("/user")
    public String user(Principal principal) {
        return "Hello, " + principal.getName() + "!";
    }

    // Maneja el login
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody UserDTO userDTO) {
        try {
            // Llama al Auth Service para validar las credenciales y obtener un token JWT
            String url = authServiceUrl + "/auth/login";

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            // Crea un HttpEntity con el UserDTO
            HttpEntity<UserDTO> request = new HttpEntity<>(userDTO, headers);

            // Realiza la solicitud POST
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, request, String.class);

            // Retorna el token JWT generado por el Auth Service
            return ResponseEntity.ok(response.getBody());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Error durante el login: " + e.getMessage());
        }
    }


    // Maneja el logout
    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpServletRequest request, HttpServletResponse response) {
        try {
            // Llama al Auth Service para manejar el logout
            String url = authServiceUrl + "/auth/logout";

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            // Invalida la autenticación actual
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth != null) {
                new SecurityContextLogoutHandler().logout(request, response, auth);
            }

            // Envía una solicitud al Auth Service para invalidar el token JWT
            ResponseEntity<String> logoutResponse = restTemplate.exchange(url, HttpMethod.POST, null, String.class);

            return ResponseEntity.ok(logoutResponse.getBody());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error durante el logout: " + e.getMessage());
        }
    }
}