package com.service;

import com.model.login.LoginRequest;
import com.model.register.RegisterRequest;
import com.model.user.User;
import com.repository.user.UserRepository;
import com.service.key.KeyService;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;

@Service
@Slf4j
@AllArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final KeyService keyService;
    private final PasswordEncoder passwordEncoder;

    public String login(LoginRequest loginRequest) {
        byte[] claveSecreta = keyService.getSecurityKey();
        Key key = Keys.hmacShaKeyFor(claveSecreta);
        User user = userRepository.findByUsername(loginRequest.getUsername()).orElseThrow(() -> new UsernameNotFoundException(loginRequest.getUsername()));
        if (passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
            // Generar token de autenticación
            return Jwts.builder()
                    .setSubject(user.getUsername())
                    .setIssuedAt(new Date())
                    .setExpiration(new Date(System.currentTimeMillis() + 86400000)) // 24 horas
                    .signWith(key)
                    .compact();
        } else {
            throw new RuntimeException("Usuario o contraseña incorrectos");
        }
    }

    public void register(RegisterRequest registerRequest) {
        if (!userRepository.existsByUsername(registerRequest.getUsername())) {
            userRepository.save(new User(registerRequest.getId(), registerRequest.getUsername(), passwordEncoder.encode(registerRequest.getPassword()), "USER", registerRequest.getEmail()));
        } else {
            throw new RuntimeException("Usuario ya existente");
        }
    }

    public String getToken(String token) {
        Key key = Keys.hmacShaKeyFor(keyService.getSecurityKey());
        // Obtener un token de autenticación para un usuario
        User user = userRepository.findByUsername(extractUsername(token)).orElseThrow(() -> new UsernameNotFoundException(extractUsername(token)));
        return Jwts.builder()
                .setSubject(user.getUsername())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + 86400000)) // 24 horas
                .signWith(key)
                .compact();
    }

    public boolean validateToken(String token) {
        byte[] claveSecreta = keyService.getSecurityKey();
        Key key = Keys.hmacShaKeyFor(claveSecreta);
        try {
            Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token);
            return true;
        } catch (JwtException e) {
            return false;
        }
    }

    // Extract the username from the token
    public String extractUsername(String token) {
        Key key = Keys.hmacShaKeyFor(keyService.getSecurityKey());
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody();
        return claims.getSubject();
    }
}