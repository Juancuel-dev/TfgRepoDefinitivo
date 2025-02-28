package com.service;

import com.model.UserDTO;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Date;
import java.util.List;

@Service
public class AuthService {

    private final RestTemplate restTemplate;

    @Value("${user.service.url}") // URL del User Service
    private String userServiceUrl;

    public AuthService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public String validateCredentials(UserDTO userDTO) {
        // Llama al User Service para validar las credenciales
        String url = userServiceUrl + "/users/auth"; // Asegúrate de que la URL sea correcta
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<UserDTO> request = new HttpEntity<>(userDTO, headers);
        ResponseEntity<UserDTO> response = restTemplate.exchange(url, HttpMethod.GET, request, UserDTO.class);

        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            // Obtén los roles dinámicamente desde la respuesta del UserDTO
            List<String> roles = response.getBody().getRoles();

            // Genera un token JWT si las credenciales son válidas
            String SECRET_KEY = System.getenv("JWT_SECRET_KEY"); // Usa una clave secreta almacenada de manera segura
            long EXPIRATION_TIME = 864_000_000; // 10 días en milisegundos

            return Jwts.builder()
                    .setSubject(response.getBody().getUsername())
                    .claim("authorities", roles) // Usamos los roles dinámicos aquí
                    .setIssuedAt(new Date())
                    .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                    .signWith(Keys.hmacShaKeyFor(SECRET_KEY.getBytes()))
                    .compact();
        } else {
            throw new RuntimeException("Credenciales inválidas");
        }
    }

}
