package com.controller;

import com.model.LoginRequest;
import com.service.auth.AuthService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@Slf4j
@RequestMapping("/auth")
@AllArgsConstructor
public class AuthController {

    private AuthService authService;

    // Endpoint para el login
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        try {
            String token = (String) authService.login(loginRequest).getBody();
            if(token != null) {

                return ResponseEntity.ok().body(Map.of("token", token));
            } // Devuelve el token JWT
        } catch (Exception e) {
            log.info("Error al hacer login" );
            e.printStackTrace();// Manejo de errores
        }
        return ResponseEntity.status(401).body("Credenciales inválidas");
    }
}



