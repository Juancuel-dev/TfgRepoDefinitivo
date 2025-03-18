package com.service;

import com.model.login.LoginRequest;
import com.model.register.RegisterRequest;
import com.model.user.User;
import com.model.user.UserDTO;
import com.repository.user.UserRepository;
import com.util.UserMapper;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;

    public UserDTO signup(RegisterRequest input) {

        User user = new User();
        user.setEmail(input.getEmail());
        user.setUsername(input.getUsername());
        user.setPassword(passwordEncoder.encode(input.getPassword()));
        user.setRole("USER");

        return UserMapper.INSTANCE.userToUserDTO(userRepository.save(user));
    }

    public UserDTO authenticate(LoginRequest input) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        input.getUsername(),
                        input.getPassword()
                )
        );

        return UserMapper.INSTANCE.userToUserDTO(userRepository.findByUsername(input.getUsername())
                .orElseThrow());
    }
}
