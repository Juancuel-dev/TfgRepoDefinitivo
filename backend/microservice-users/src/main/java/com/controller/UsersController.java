package com.controller;

import com.model.User;
import com.model.UserDTO;
import com.service.UserService;
import com.util.UserMapper;
import com.util.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UsersController {

    private final UserService userService;

    @GetMapping
    public ResponseEntity<List<User>> findAll(@AuthenticationPrincipal Jwt jwt) {
        try{
            return ResponseEntity.ok(userService.findAll(jwt));
        }catch(UnauthorizedException ue){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> findById(@AuthenticationPrincipal Jwt jwt,
                                         @PathVariable String id) {
        try{
            return ResponseEntity.ok(userService.findById(jwt,id));
        }catch(UnauthorizedException | UsernameNotFoundException e){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @PutMapping("/update")
    public ResponseEntity<User> updateUser(@AuthenticationPrincipal Jwt jwt, @RequestBody User user) {
        try {
            return ResponseEntity.ok(userService.edit(jwt, user));
        } catch (UnauthorizedException | UsernameNotFoundException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @PutMapping("/update-image/{imageId}")
    public ResponseEntity<User> updateImage(@AuthenticationPrincipal Jwt jwt, @PathVariable String imageId) {
        try {
            return ResponseEntity.ok(userService.editImage(jwt, imageId));
        } catch (UnauthorizedException | UsernameNotFoundException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @PostMapping("/register")
    public ResponseEntity<User> save(@RequestBody User user) {
        User savedUser = userService.save(user);
        return ResponseEntity.created(URI.create("/users/" + savedUser.getId()))
                .body(savedUser);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteById(@AuthenticationPrincipal Jwt jwt, @PathVariable String id) {
        try{
            userService.deleteById(jwt,id);
        }catch(UnauthorizedException | UsernameNotFoundException e){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/user-info")
    public String getUserInfo(@AuthenticationPrincipal Jwt jwt) {
        String username = jwt.getClaim("username"); // "sub" en JWT
        String role = jwt.getClaim("role"); // Claims personalizados
        String email = jwt.getClaim("email");

        return "Usuario: " + username + " | Rol: " + role + " | Email: " + email;
    }

    @GetMapping("/me")
    public UserDTO getMySelf(@AuthenticationPrincipal Jwt jwt) throws UnauthorizedException {

        log.info(jwt.getSubject());
        try {
            // Obtén el claim "username" del token JWT
            String username = jwt.getClaim("username");
            if (username == null) {
                throw new UnauthorizedException("Username not found in JWT");
            }

            // Busca al usuario por el username
            UserDTO aux = UserMapper.INSTANCE.toUserDTO(userService.findByUsername(jwt));
            log.info("User info: {}", aux);
            return aux;
        } catch (UsernameNotFoundException | UnauthorizedException e) {
            log.error("User not found: {}", e.getMessage());
            throw new UnauthorizedException("User not found");
        }
    }

}