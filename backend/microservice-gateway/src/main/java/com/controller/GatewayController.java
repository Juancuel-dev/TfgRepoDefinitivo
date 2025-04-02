package com.controller;

import com.model.LoginRequest;
import com.model.register.RegisterUsersRequest;
import com.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@Slf4j
@RestController
@RequestMapping("/gateway")
public class GatewayController {

    private static final String USER_SERVICE = "microservice-users";
    private static final String GAME_SERVICE = "microservice-games";
    private static final String CART_SERVICE = "microservice-orders";

    private final AuthService authService;

    public GatewayController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<String> login(@RequestBody LoginRequest loginRequest) {
        log.info("Login attempt for user: {}", loginRequest.getUsername());
        ResponseEntity<String> response = authService.login(loginRequest);
        log.info("Login status: {}", response.getStatusCode());
        return response;
    }

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody RegisterUsersRequest registerRequest) {
        log.info("Registration attempt for user: {}", registerRequest.getEmail());
        ResponseEntity<String> response = authService.register(registerRequest);
        if (response.getStatusCode() == HttpStatus.CREATED) {
            log.info("User registered successfully: {}", registerRequest.getEmail());
        }
        return response;
    }

    @RequestMapping(
            value = "/users/**",
            method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.PATCH}
    )
    public ResponseEntity<Object> usersProxy(HttpServletRequest request) {
        log.debug("Proxying user request to path: {}", request.getRequestURI());
        return authService.proxyRequest(USER_SERVICE, request);
    }

    @RequestMapping(
            value = "/games/**",
            method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.PATCH}
    )
    public ResponseEntity<Object> gamesProxy(HttpServletRequest request) {
        log.debug("Proxying game request to path: {}", request.getRequestURI());
        return authService.proxyRequest(GAME_SERVICE, request);
    }

    @RequestMapping(
            value = "/order/**",
            method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.PATCH}
    )
    public ResponseEntity<Object> cartProxy(HttpServletRequest request) {
        log.debug("Proxying cart request to path: {}", request.getRequestURI());
        return authService.proxyRequest(CART_SERVICE, request);
    }

    @GetMapping("/me")
    public ResponseEntity<Object> myself(@RequestHeader(HttpHeaders.AUTHORIZATION) String token) {
        log.debug("Fetching user info");
        ResponseEntity<Object> response = authService.myself(token);
        log.debug("User info status: {}", response.getStatusCode());
        return response;
    }
}