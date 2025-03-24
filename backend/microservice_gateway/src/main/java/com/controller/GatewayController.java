package com.controller;

import com.model.LoginRequest;
import com.model.register.RegisterUsersRequest;
import com.service.AuthService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Slf4j
@RestController
@RequestMapping("/gateway")
public class GatewayController {

    private final AuthService authService;

    public GatewayController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public Mono<ResponseEntity<String>> login(@RequestBody LoginRequest loginRequest) {
        return authService.login(loginRequest);
    }

    @PostMapping("/register")
    public Mono<ResponseEntity<String>> register(@RequestBody RegisterUsersRequest registerUsersRequest) {
        return authService.register(registerUsersRequest);
    }

    @RequestMapping("/users/**")
    public Mono<ResponseEntity<?>> usersProxy(ServerWebExchange exchange) {
        return authService.proxyUsersRequest(exchange);
    }

    @RequestMapping("/games/**")
    public Mono<ResponseEntity<?>> gamesProxy(ServerWebExchange exchange) {
        return authService.proxyGamesRequest(exchange);
    }

    @RequestMapping("/cart/**")
    public Mono<ResponseEntity<?>> cartProxy(ServerWebExchange exchange) {
        return authService.proxyCartRequest(exchange);
    }

    @GetMapping("/me")
    public Mono<ResponseEntity<?>> myself(@RequestHeader("Authorization") String token) {
        return authService.myself(token);
    }
}