package com.service.auth;

import com.model.LoginRequest;
import com.model.User;
import com.service.user.UserService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
@Slf4j
@AllArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final UserService userService;

    public ResponseEntity<?> login(LoginRequest loginRequest) {
        try {
            // Autenticar al usuario
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getUsername(),
                            loginRequest.getPassword()
                    )
            );

            // Si la autenticación es exitosa, obtenemos el usuario
            User aux = userService.findByUsername(loginRequest.getUsername());

            // Generamos el token JWT
            String token = jwtService.generateToken(aux);

            // Retornamos el token y la información básica del usuario
            Map<String, Object> response = new HashMap<>();
            response.put("token", token);
            response.put("user", aux);

            return ResponseEntity.ok(response);

        } catch (Exception ex) {
            log.info("Access Denied: Invalid credentials for user {}", loginRequest.getUsername());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
        }
    }
}