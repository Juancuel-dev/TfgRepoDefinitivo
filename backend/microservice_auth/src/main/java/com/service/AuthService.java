package com.service;

import com.model.LoginRequest;
import com.model.RegisterRequest;
import com.model.User;
import lombok.AllArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@AllArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final RestTemplate restTemplate;

    public ResponseEntity<?> login(LoginRequest loginRequest) {
        // Llamar al microservicio de usuarios para autenticar
        String url = "http://localhost:8081/users/auth";

        // Configurar los headers
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // Crear el cuerpo de la solicitud con el username y password
        HttpEntity<String> request = new HttpEntity<>(loginRequest.getUsername(), headers);

        // Realizar la solicitud POST al microservicio de usuarios
        ResponseEntity<User> response = restTemplate.exchange(
                url, HttpMethod.POST, request, User.class);

        // Si la autenticación es exitosa, generar el token JWT
        if (response.getStatusCode() == HttpStatus.OK) {
            // Obtener los detalles del usuario desde la respuesta
            User user = response.getBody();

            // Autenticar al usuario en el contexto de seguridad
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword())
            );

            // Generar el token JWT
            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            String token = jwtService.generateToken(userDetails);

            // Devolver el token en la respuesta
            return ResponseEntity.ok().body(token);
        } else {
            // Si la autenticación falla, devolver un error genérico
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Authentication failed");
        }
    }

    public ResponseEntity<?> register(RegisterRequest user) {
        // Llamar al microservicio de usuarios para registrar al usuario
        String url = "http://localhost:8081/auth/register";

        // Configurar los headers
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // Crear el cuerpo de la solicitud
        HttpEntity<RegisterRequest> request = new HttpEntity<>(user, headers);

        // Realizar la solicitud POST al microservicio de usuarios
        return restTemplate.exchange(url, HttpMethod.POST, request, String.class);
    }
}