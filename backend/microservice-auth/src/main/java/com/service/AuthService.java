package com.service;

import com.model.login.LoginRequest;
import com.model.register.RegisterRequest;
import com.model.user.User;
import com.model.user.UserDTO;
import com.repository.user.UserRepository;
import com.util.UserMapper;
import com.util.exception.ClienteNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;

    public UserDTO signup(RegisterRequest input) {

        User user = UserMapper.INSTANCE.toUser(input);
        user.setPassword(passwordEncoder.encode(input.getPassword()));

        return UserMapper.INSTANCE.userToUserDTO(userRepository.save(user));
    }
    public UserDTO cambiarContrasenia(String token, String password) throws ClienteNotFoundException {
        if(token.contains("Bearer ")){
            token = token.substring(+7);
        }
        User user = userRepository.findById(jwtService.extractClientId(token)).orElseThrow(()-> new ClienteNotFoundException("Cliente no encontrado"));
        user.setPassword(passwordEncoder.encode(password));
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

    public UserDTO loadByClientId(String clientId) throws ClienteNotFoundException {
        return UserMapper
                .INSTANCE
                .userToUserDTO(userRepository
                                    .findById(clientId)
                                    .orElseThrow(()-> new ClienteNotFoundException("Cliente " + clientId + " no encontrado")));
    }

    public String getEmail(String clientId) throws ClienteNotFoundException {
        return userRepository.findById(clientId).orElseThrow(()-> new ClienteNotFoundException("Cliente no encontrado con id " + clientId)).getEmail();
    }

    public void delete(String token,String id) {
        if(token.contains("Bearer ")){
            token = token.substring(+7);
        }
        if(jwtService.hasRole(token,"ADMIN")) {
            log.info("Eliminando usuario");
            userRepository.deleteById(id);
        }
    }
}
