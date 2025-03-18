package com.controller;

import com.model.login.LoginRequest;
import com.model.login.LoginResponse;
import com.model.register.RegisterRequest;
import com.model.user.User;
import com.model.user.UserDTO;
import com.service.AuthService;
import com.service.JwtService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequestMapping("/auth")
@RestController
@RequiredArgsConstructor
public class AuthController {
    private final JwtService jwtService;

    private final AuthService authenticationService;

    @PostMapping("/signup")
    public ResponseEntity<UserDTO> register(@RequestBody RegisterRequest registerUserDto) {
        UserDTO registeredUser = authenticationService.signup(registerUserDto);

        return ResponseEntity.ok(registeredUser);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> authenticate(@RequestBody LoginRequest loginUserDto) {
        UserDTO authenticatedUser = authenticationService.authenticate(loginUserDto);

        String jwtToken = jwtService.generateToken(authenticatedUser);

        LoginResponse loginResponse = new LoginResponse();
        loginResponse.setToken(jwtToken);
        loginResponse.setExpiresIn(jwtService.getExpirationTime());

        return ResponseEntity.ok(loginResponse);
    }
}