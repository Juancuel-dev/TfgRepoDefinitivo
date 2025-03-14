package com.service.auth;

import com.model.login.LoginRequest;
import com.model.register.RegisterRequest;
import com.model.token.TokenRequest;
import com.model.user.User;
import com.repository.UserRepository;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import jakarta.persistence.EntityNotFoundException;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;


@Service
@Slf4j
@AllArgsConstructor
public class AuthService {

    private UserRepository userRepository;

    private static final Key secretKey = Keys.secretKeyFor(SignatureAlgorithm.HS512);

    private PasswordEncoder passwordEncoder;

    public String login(LoginRequest loginRequest) {

        User user = userRepository.findByUsername(loginRequest.getUsername()).orElseThrow(EntityNotFoundException::new);
        if (passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
            // Generar token de autenticación
            return Jwts.builder()
                    .setSubject(user.getUsername())
                    .setIssuedAt(new Date())
                    .setExpiration(new Date(System.currentTimeMillis() + 86400000)) // 24 horas
                    .signWith(secretKey)
                    .compact();

        } else {
            throw new RuntimeException("Usuario o contraseña incorrectos");
        }
    }


    public void register(RegisterRequest registerRequest) {
        // Registrar a un nuevo usuario
        User user = new User();
        user.setUsername(registerRequest.getUsername());
        user.setPassword(passwordEncoder.encode(registerRequest.getPassword()));
        user.setEmail(registerRequest.getEmail());
        user.setRole("USER");
        userRepository.save(user);
    }

    public String getToken(TokenRequest tokenRequest) {

        // Obtener un token de autenticación para un usuario
        User user = userRepository.findByUsername(tokenRequest.getUsername()).orElseThrow(EntityNotFoundException::new);
        return Jwts.builder()
                .setSubject(user.getUsername())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + 86400000)) // 24 horas
                .signWith(secretKey)
                .compact();

        }

    public boolean validateToken(TokenRequest tokenRequest) {
        // Validar un token de autenticación
        try {
            Jwts.parserBuilder()
                    .setSigningKey(secretKey)
                    .build()
                    .parseClaimsJws(tokenRequest.getToken());
            return true;
        } catch (JwtException e) {
            return false;
        }
    }
}

