package com.service;

import com.model.user.UserDTO;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import java.security.Key;
import java.util.*;
import java.util.function.Function;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

@Service
public class JwtService {
    @Value("dGhlIHNhbXBsZSBub3RlIG9mIHRoZSBzdGF0ZW1lbnQgaXMgdGhlIHRydWUgdGhlcnJpY2FsIGtleQ")
    private String secretKey;

    @Value("86400000")
    private long jwtExpiration;

    public String extractUsername(String token) {
        return extractClaim(token, claims -> claims.get("username", String.class));
    }

    public String extractClientId(String token) {
        return extractClaim(token, claims -> claims.get("clientId", String.class));
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    public String generateToken(UserDetails userDetails) {
        return buildToken(userDetails, jwtExpiration);
    }

    private String buildToken(
            UserDetails userDetails,
            long expirationTime
    ) {
        Map<String, Object> extraClaims = new HashMap<>();
        extraClaims.put("clientId", ((UserDTO)userDetails).getClientId());
        extraClaims.put("username", userDetails.getUsername());
        extraClaims.put("role", userDetails.getAuthorities().stream().findFirst().get().getAuthority());
        return Jwts
                .builder()
                .setClaims(extraClaims)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + expirationTime))
                .signWith(getSignInKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public boolean isTokenValid(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        final String authority = extractClaim(token, claims -> claims.get("role", String.class));
        return (username.equals(userDetails.getUsername())) && authority.equals(userDetails.getAuthorities().stream().findFirst().get().getAuthority()) && !isTokenExpired(token);
    }

    public boolean isTokenValid(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(getSignInKey()).build().parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    private Claims extractAllClaims(String token) {
        try {
            return Jwts.parserBuilder()
                    .setSigningKey(getSignInKey())
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (JwtException e) {
            // Maneja la excepción
            return null;
        }
    }


    private Key getSignInKey() {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public List<String> extractAuthorities(String token) {
        return Collections.singletonList(extractClaim(token, claims -> claims.get("role", String.class)));
    }

    public boolean hasRole(String token, String role) {
        return extractAuthorities(token).contains(role);
    }
}
