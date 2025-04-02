package com.viewnext.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.viewnext.model.Auth;
import com.viewnext.model.LoginRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;


@Service
@RequiredArgsConstructor
public class ScheduledService {

    private final Auth auth;

    @Value("${auth.username}")
    private String username;
    @Value("${auth.password}")
    private String password;
    private final RestTemplate restTemplate;

    @Scheduled(fixedDelay = 60000) // 1 minuto
    public void fixSorteoEstado(){
        try{
            callLogin();
            callSorteos();
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    public void callLogin() throws JsonProcessingException {
        this.auth.setUsername(username);
        this.auth.setPassword(password);
        String url = "http://localhost:8084/auth/login";
        HttpHeaders headers = new HttpHeaders();
        HttpEntity<LoginRequest> entity = new HttpEntity<>(new LoginRequest(username,password), headers);
        String json = restTemplate.postForObject(url, entity, String.class);
        ObjectMapper mapper = new ObjectMapper();
        JsonNode jsonNode = mapper.readTree(json);
        String token = jsonNode.get("token").asText();
        auth.setToken(token);
    }


    public void callSorteos(){
        String url = "http://localhost:8086/sorteo/schedule";
        String tokenFixed = "Bearer " + this.auth.getToken();
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", tokenFixed);
        HttpEntity<String> entityS = new HttpEntity<>("", headers);
        restTemplate.exchange(url, HttpMethod.GET, entityS, String.class).getBody();
    }

}
