package com.controller;

import com.model.LoginRequest;
import com.model.register.RegisterUsersRequest;
import com.service.AuthService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/gateway")
public class GatewayController {

    private final AuthService authService;

    public GatewayController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<String> login(@RequestBody LoginRequest loginRequest) {
        return authService.login(loginRequest);
    }

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody RegisterUsersRequest registerUsersRequest) {
        return authService.register(registerUsersRequest);
    }

    @PostMapping("/register-key")
    public ResponseEntity<String> registerKey() {
        return authService.registerKey();
    }

    @GetMapping("/users/**")
    public ResponseEntity<?> redirectToMicroserviceUsers(@RequestHeader("Authorization") String token) {
        return authService.redirectToMicroserviceUsers(token);
    }

    @GetMapping("/games/**")
    public ResponseEntity<?> redirectToMicroserviceGames(@RequestHeader("Authorization") String token) {
        return authService.redirectToMicroserviceGames(token);
    }

    @GetMapping("/cart/**")
    public ResponseEntity<?> redirectToMicroserviceCart(@RequestHeader("Authorization") String token) {
        return authService.redirectToMicroserviceCart(token);
    }

    @GetMapping("/me")
    public ResponseEntity<?> myself(@RequestHeader("Authorization") String token) {
        return authService.myself(token);
    }
}