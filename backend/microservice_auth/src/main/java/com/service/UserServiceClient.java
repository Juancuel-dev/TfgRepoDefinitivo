package com.service;

import com.model.RegisterRequest;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@AllArgsConstructor
public class UserServiceClient {

    private static final String USER_SERVICE_URL = "http://localhost:8081/users";

    private final RestTemplate restTemplate;

    public ResponseEntity<?> createUser(RegisterRequest user) {
        return restTemplate.postForEntity(USER_SERVICE_URL, user, ResponseEntity.class);
    }

    public ResponseEntity<?> getUserByUsername(String username) {
        String url = USER_SERVICE_URL + "/" + username;
        return restTemplate.getForEntity(url, ResponseEntity.class);
    }
}
