package com.service;

import com.model.LoginRequest;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class SchedulerService {

    private final RestTemplate restTemplate;
    private String token;

    @Scheduled(fixedRate = 720000)
    @PostConstruct
    public void getToken(){
        this.token = restTemplate.postForObject("http://microservice-auth/auth/login",new LoginRequest("scheduler","admin"),String.class);
    }

    @Scheduled(fixedRate = 60000)
    public void hola(){
        if(!this.token.isEmpty()){
            System.out.println("hola");
        }else{
            System.out.println("adios");
        }
    }


}
