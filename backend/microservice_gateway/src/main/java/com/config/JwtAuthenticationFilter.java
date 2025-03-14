package com.config;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

import javax.crypto.SecretKey;

@Component
public class JwtAuthenticationFilter implements WebFilter {

    private static final SecretKey secretKey = Keys.secretKeyFor(SignatureAlgorithm.HS512);

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        // Verificar la validez del token JWT
        String token = exchange.getRequest().getHeaders().getFirst("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
            try {
                Jws<Claims> jws = Jwts.parserBuilder()
                        .setSigningKey(secretKey)
                        .build()
                        .parseClaimsJws(token);
                // Token válido, permitir el acceso
                return chain.filter(exchange);
            } catch (JwtException e) {
                // Token inválido, denegar el acceso
                exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                return Mono.empty();
            }
        } else {
            // No hay token, denegar el acceso
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return Mono.empty();
        }
    }
}