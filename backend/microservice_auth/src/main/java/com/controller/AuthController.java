package com.controller;

import com.model.login.LoginRequest;
import com.model.register.RegisterRequest;
import com.model.token.TokenRequest;
import com.model.user.User;
import com.service.auth.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;


@RestController
@Slf4j
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<String> login(@RequestBody LoginRequest loginRequest) {
        String token = authService.login(loginRequest);
        return ResponseEntity.ok(token);
    }

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody RegisterRequest registerRequest) {
        authService.register(registerRequest);
        return ResponseEntity.status(HttpStatus.CREATED).body("Usuario registrado con éxito");
    }


    @PostMapping("/token")
    public ResponseEntity<String> getToken(@RequestBody TokenRequest tokenRequest) {
        String token = authService.getToken(tokenRequest);
        return ResponseEntity.ok(token);
    }

    @PostMapping("/validate-token")
    public ResponseEntity<Boolean> validateToken(@RequestBody TokenRequest tokenRequest) {
        boolean isValid = authService.validateToken(tokenRequest);
        return ResponseEntity.ok(isValid);
    }

    @GetMapping("/current-role")
    public ResponseEntity<String> getCurrentRole(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(user.getRole());
    }
}


