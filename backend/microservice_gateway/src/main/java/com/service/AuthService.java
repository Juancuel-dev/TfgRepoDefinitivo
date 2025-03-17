package com.service;
import com.model.LoginRequest;
import com.model.User;
import com.model.register.RegisterUsersRequest;
import com.util.RegisterRequestMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.UUID;

@Service
public class AuthService {

    private final Authentication authentication;

    @Value("${auth.service.url}/auth")
    private String authServiceUrl;

    @Value("${users.service.url}/users")
    private String userServiceUrl;

    @Value("${games.service.url}/games")
    private String gamesServiceUrl;

    @Value("${cart.service.url}/cart")
    private String cartServiceUrl;
    private final RestTemplate restTemplate;

    public AuthService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
        this.authentication = SecurityContextHolder.getContext().getAuthentication();
    }

    public boolean isValid(String token){
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", token);
        HttpEntity<String> entity = new HttpEntity<>(headers);
        return Boolean.TRUE.equals(restTemplate.exchange("http://localhost:8084/auth/validate-token", HttpMethod.POST, entity, Boolean.class).getBody());
    }

    public String currentRole(String token){
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", "Bearer " + token);
        HttpEntity<String> entity = new HttpEntity<>(headers);
        return restTemplate.exchange("http://localhost:8080/auth/current-role", HttpMethod.POST, entity, String.class).getBody();
    }

    public boolean isAuthenticated(){

        return authentication != null
                && authentication.isAuthenticated();
    }

    public boolean isSameUser(String username){
        if (authentication.getPrincipal() instanceof UserDetails) {
            return ((UserDetails) authentication.getPrincipal()).getUsername().equals(username);
        } else {
            return false;
        }
    }

    public ResponseEntity<String> register(RegisterUsersRequest register) {

        register.setId(UUID.randomUUID().toString());
        try {
            ResponseEntity<String> responseAuth = restTemplate.postForEntity(authServiceUrl + "/register", RegisterRequestMapper.INSTANCE.toRegisterAuthRequest(register), String.class);
            ResponseEntity<String> responseUsers = restTemplate.postForEntity(userServiceUrl + "/register", register, String.class);
            if (responseAuth.getStatusCode() == HttpStatus.CREATED && responseUsers.getStatusCode() == HttpStatus.CREATED) {
                return ResponseEntity.status(HttpStatus.CREATED).body("Usuario registrado con éxito");
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error al registrar usuario, BAD REQUEST");
            }
        } catch (HttpClientErrorException e) {
            if (e.getStatusCode() == HttpStatus.BAD_REQUEST) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error al registrar usuario, BAD REQUEST");
            } else {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error interno del servidor");
            }
        }
    }


    public ResponseEntity<String> login(LoginRequest loginRequest){
        ResponseEntity<String> response = restTemplate.postForEntity(authServiceUrl + "/login", loginRequest, String.class);
        if (response.getStatusCode() == HttpStatus.OK) {
            return ResponseEntity.status(HttpStatus.OK).body(response.getBody());
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Error al hacer login usuario");
        }
    }

    public ResponseEntity<String> registerKey() {
        ResponseEntity<String> response = restTemplate.postForEntity(authServiceUrl + "register", null, String.class);
        if (response.getStatusCode() == HttpStatus.CREATED) {
            return ResponseEntity.status(HttpStatus.CREATED).body("Clave registrada con éxito");
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Error al registrar usuario");
        }
    }

    public ResponseEntity<?> redirectToMicroserviceUsers(@RequestHeader("Authorization") String token) {
        if (isValid(token)) {
            return redirectRequest(userServiceUrl, token);
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    public ResponseEntity<?> redirectToMicroserviceGames(@RequestHeader("Authorization") String token) {
        if (isValid(token)) {
            return redirectRequest(gamesServiceUrl, token);
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    public ResponseEntity<?> redirectToMicroserviceCart(@RequestHeader("Authorization") String token) {
        if (isValid(token)) {
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

    public ResponseEntity<?> myself(String token){
        ResponseEntity<User> response = restTemplate.postForEntity(userServiceUrl + "/me", token, User.class);
        if (response.getStatusCode() == HttpStatus.OK) {
            return ResponseEntity.status(HttpStatus.OK).body(response.getBody());
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Error al hacer login usuario");
        }
    }

}
