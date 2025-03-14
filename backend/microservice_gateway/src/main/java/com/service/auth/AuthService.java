package com.service.auth;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class AuthService {

    private final Authentication authentication;

    public AuthService(Authentication authentication) {
        this.authentication = authentication;
    }
    public AuthService() {
        this.authentication = SecurityContextHolder.getContext().getAuthentication();
    }

    public boolean isValid(String token){
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", "Bearer " + token);
        HttpEntity<String> entity = new HttpEntity<>(headers);
        return Boolean.TRUE.equals(restTemplate.exchange("http://localhost:8080/auth/validate-token", HttpMethod.POST, entity, Boolean.class).getBody());
    }

    public String currentRole(String token){
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", "Bearer " + token);
        HttpEntity<String> entity = new HttpEntity<>(headers);
        return restTemplate.exchange("http://localhost:8080/auth/current-role", HttpMethod.POST, entity, String.class).getBody();
    }

    public boolean isAuthenticated(){

        return authentication != null
                && authentication.isAuthenticated();
    }

    public boolean isSameUser(String username){
        if (authentication.getPrincipal() instanceof UserDetails) {
            return ((UserDetails) authentication.getPrincipal()).getUsername().equals(username);
        } else {
            return false;
        }
    }

}
