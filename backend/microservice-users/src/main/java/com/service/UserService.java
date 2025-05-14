package com.service;

import com.model.User;
import com.repository.UserRepository;
import com.util.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.ReactiveUserDetailsPasswordService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

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
        user.setImagen(0);
        return userRepository.save(user);
    }

    public Integer getUserImage(String username){
        return userRepository.findByUsername(username).orElseThrow(()->new UsernameNotFoundException("Usuario " + username +" no encontrado")).getImagen();
    }

    public User edit(Jwt jwt,User user) throws UnauthorizedException {
        if(userRepository.existsById(user.getId())){

            if(jwt.getClaim("role").equals("ADMIN") || jwt.getClaim("username").equals(user.getUsername())) {
                return userRepository.save(user);
            }else{
                throw new UnauthorizedException("No estas autorizado para realizar esta accion");
            }
        }else{
            throw new UsernameNotFoundException("Usuario no encontrado");
        }
    }

    public User editImage(Jwt jwt,String imageId) throws UnauthorizedException {

        User u = userRepository.findByUsername(jwt.getClaim("username")).orElseThrow(()->new UsernameNotFoundException("Usuario no encontrado"));
        u.setImagen(Integer.parseInt(imageId));
                return userRepository.save(u);

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