package com.service;

import com.model.AuthenticationResponse;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.stream.Collectors;

public class JwtService {

    private static RestTemplate restTemplate = new RestTemplate();

    public static boolean isTokenValid(String token) {
        String url = "http://microservice-auth/auth/validate-token";
        return Boolean.TRUE.equals(restTemplate.postForObject(url, token, Boolean.class));
    }

    public static Authentication getAuthentication(String token) {
        String url = "http://microservice-auth/auth/token-info";
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", token);
        HttpEntity<String> entity = new HttpEntity<>("", headers);
        ResponseEntity<AuthenticationResponse> response = restTemplate.exchange(url, HttpMethod.GET, entity, AuthenticationResponse.class);
        AuthenticationResponse authenticationResponse = response.getBody();
        if (authenticationResponse != null) {
            String username = authenticationResponse.getUsername();
            List<String> authorities = authenticationResponse.getAuthorities();
            return new UsernamePasswordAuthenticationToken(username, null, authorities.stream().map(SimpleGrantedAuthority::new).collect(Collectors.toList()));
        } else {
            return null;
        }
    }

    public static String getUsernameFromToken(String token) {
        String url = "http://localhost:8084/auth/token-info";
        HttpHeaders headers = new HttpHeaders();
        token=token.replace("Bearer ", "");
        headers.set("Authorization", token);
        HttpEntity<String> entity = new HttpEntity<>("", headers);
        ResponseEntity<AuthenticationResponse> response = restTemplate.exchange(url, HttpMethod.GET, entity, AuthenticationResponse.class);
        AuthenticationResponse authenticationResponse = response.getBody();
        if (authenticationResponse != null) {

            return authenticationResponse.getUsername();
        } else {
            return null;
        }
    }
}
