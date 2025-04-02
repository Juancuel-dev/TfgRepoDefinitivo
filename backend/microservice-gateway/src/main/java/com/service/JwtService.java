package com.service;

import com.model.AuthenticationResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class JwtService {

    private final RestTemplate restTemplate;
    private final String baseUrl = "http://microservice-auth/auth";

    public Boolean isTokenValid(String token) {
        HttpHeaders headers = new HttpHeaders();
        String cleanToken = token.replace("Bearer ", "");
        headers.set(HttpHeaders.AUTHORIZATION, cleanToken);
        HttpEntity<String> entity = new HttpEntity<>("", headers);

        return restTemplate.exchange(
                baseUrl + "/validate-token",
                HttpMethod.POST,
                entity,
                Boolean.class
        ).getBody();
    }

    public Authentication getAuthentication(String token) {
        AuthenticationResponse auth = callAuthMicroServiceAuth(token);
        if (auth != null) {
            return new UsernamePasswordAuthenticationToken(
                    auth.getUsername(),
                    null,
                    auth.getAuthorities().stream()
                            .map(SimpleGrantedAuthority::new)
                            .collect(Collectors.toList())
            );
        }
        return null;
    }

    public String getUsernameFromToken(String token) {
        AuthenticationResponse auth = callAuthMicroServiceAuth(token);
        return auth != null ? auth.getUsername() : null;
    }

    public String getIdFromToken(String token) {
        AuthenticationResponse auth = callAuthMicroServiceAuth(token);
        return auth != null ? auth.getClientId() : null;
    }

    public SimpleGrantedAuthority getRoleFromToken(String token) {
        AuthenticationResponse auth = callAuthMicroServiceAuth(token);
        if (auth != null && !auth.getAuthorities().isEmpty()) {
            return new SimpleGrantedAuthority(auth.getAuthorities().get(0));
        }
        throw new RuntimeException("No authorities found in token");
    }

    private AuthenticationResponse callAuthMicroServiceAuth(String token) {
        HttpHeaders headers = new HttpHeaders();
        String cleanToken = token.replace("Bearer ", "");
        headers.set(HttpHeaders.AUTHORIZATION, cleanToken);
        HttpEntity<String> entity = new HttpEntity<>("", headers);

        return restTemplate.exchange(
                baseUrl + "/token-info",
                HttpMethod.GET,
                entity,
                AuthenticationResponse.class
        ).getBody();
    }
}