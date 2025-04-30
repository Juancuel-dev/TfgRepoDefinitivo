package com.service;

import com.model.User;
import com.repository.UserRepository;
import com.util.Role;
import com.util.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public List<User> findAll(Jwt jwt) throws UnauthorizedException {
        if (jwt.getClaim("role").equals("ADMIN")) {
            return userRepository.findAll();
        } else {
            throw new UnauthorizedException("No estas autorizado para realizar esta accion");
        }
    }

    public User findById(Jwt jwt,String id) throws UnauthorizedException,UsernameNotFoundException {
        if (jwt.getClaim("role").equals("ADMIN")) {
            return userRepository.findById(id).orElseThrow(()->new UsernameNotFoundException("Usuario no encontrado."));
        } else {
            throw new UnauthorizedException("No estas autorizado para realizar esta accion");
        }
    }

    public User findByUsername(Jwt jwt) throws UnauthorizedException {
            return userRepository.findByUsername(jwt.getClaim("username")).orElseThrow(()->new UsernameNotFoundException("Usuario no encontrado."));
    }

    public User save(User user){
        String encryptedPassword = passwordEncoder.encode(user.getPassword());
        user.setPassword(encryptedPassword);
        return userRepository.save(user);
    }

    public User edit(Jwt jwt,User user) throws UnauthorizedException {
        if(userRepository.existsById(user.getId())){

            if(jwt.getClaim("role").equals("ADMIN") || jwt.getClaim("username").equals(user.getUsername())) {

                String encryptedPassword = passwordEncoder.encode(user.getPassword());
                user.setPassword(encryptedPassword);
                return userRepository.save(user);
            }else{
                throw new UnauthorizedException("No estas autorizado para realizar esta accion");
            }
        }else{
            throw new UsernameNotFoundException("Usuario no encontrado");
        }
    }

    public void deleteById(Jwt jwt, String id) throws UnauthorizedException, UsernameNotFoundException {
        if (!userRepository.existsById(id)) {
            throw new UsernameNotFoundException("Usuario con id " + id + " no encontrado");
        }
        if(jwt.getClaim("role").equals("ADMIN")|| jwt.getClaim("clientId").equals(id)) {

            userRepository.deleteById(id);
        }else{
            throw new UnauthorizedException("No estas autorizado para realizar esta accion");
        }
    }

}