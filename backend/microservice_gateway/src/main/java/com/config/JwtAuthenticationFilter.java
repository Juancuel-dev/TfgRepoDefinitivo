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
import java.util.List;

@Component
public class JwtAuthenticationFilter implements WebFilter {

    private static final SecretKey secretKey = Keys.secretKeyFor(SignatureAlgorithm.HS512);

    // Rutas que no requieren autenticación
    private static final List<String> PUBLIC_PATHS = List.of(
            "/gateway/login",
            "/gateway/logout",
            "/gateway/register",
            "/gateway/register-key",
            "/gateway/games"
    );

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        String path = exchange.getRequest().getURI().getPath();

        // Permitir acceso sin autenticación a rutas públicas
        if (PUBLIC_PATHS.contains(path)) {
            return chain.filter(exchange);
        }

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
                return exchange.getResponse().setComplete();
            }
        } else {
            // No hay token, denegar el acceso
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }
    }
}
