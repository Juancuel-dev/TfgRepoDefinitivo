package com.controller;

import com.model.LoginRequest;
import com.model.UserDTO;
import com.model.register.RegisterUsersRequest;
import com.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;


@Slf4j
@RestController
@RequestMapping("/gateway")
public class GatewayController {

    private static final String USER_SERVICE = "microservice-users";
    private static final String GAME_SERVICE = "microservice-games";
    private static final String CART_SERVICE = "microservice-orders";
    private static final String MAIL_SERVICE = "microservice-mail";
    private static final String AUTH_SERVICE = "microservice-auth";

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
            value = "/orders/**",
            method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.PATCH}
    )
    public ResponseEntity<Object> cartProxy(HttpServletRequest request) {
        log.debug("Proxying cart request to path: {}", request.getRequestURI());
        return authService.proxyRequest(CART_SERVICE, request);
    }

    @RequestMapping(
            value = "/mail/**",
            method = {RequestMethod.POST}
    )
    public ResponseEntity<Object> mailProxy(HttpServletRequest request) {
        log.debug("Proxying mail request to path: {}", request.getRequestURI());
        return authService.proxyRequest(MAIL_SERVICE, request);
    }

    @RequestMapping(
            value = "/auth/**",
            method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.PATCH}
    )
    public ResponseEntity<Object> authProxy(HttpServletRequest request) {
        log.debug("Proxying auth request to path: {}", request.getRequestURI());
        return authService.proxyRequest(AUTH_SERVICE, request);
    }

    @RequestMapping("/me")
    public ResponseEntity<UserDTO> getMySelf(@AuthenticationPrincipal Jwt jwt){
        log.info("El username desde el que se hace la peticion es: " + jwt.getClaim("username"));
        return authService.myself(jwt);
    }
}