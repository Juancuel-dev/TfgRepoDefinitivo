package com.controller;

import com.model.User;
import com.model.UserDTO;
import com.service.UserServiceCmdImpl;
import com.util.UserMapper;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;

@RestController
@RequestMapping("/users")
@AllArgsConstructor
public class UsersController {

    private final UserServiceCmdImpl userService;

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(userService.findAll());
    }

    @PreAuthorize("hasRole('ADMIN') ")
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable String id) {
        return ResponseEntity.ok(userService.findById(id));
    }

    @PostMapping("/register")
    public ResponseEntity<User> createUser(@Valid @RequestBody User user) {
        try{
            User createdUser = userService.save(user);
            return ResponseEntity.created(UriComponentsBuilder.fromPath("/users/{id}")
                            .buildAndExpand(createdUser.getId())
                            .toUri())
                    .body(createdUser);
        }catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }

    }

    @GetMapping("/me")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<User> getAuthenticatedUser(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(user);
    }


    @PreAuthorize("hasRole('ADMIN') ")
    @PutMapping
    public ResponseEntity<User> updateUser(@Valid @RequestBody User user) {
        try {
            return ResponseEntity.ok(userService.save(user));
        } catch (Exception ef) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PreAuthorize("hasRole('ADMIN') ")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable String id) {
        try {
            userService.deleteById(id);
            return ResponseEntity.noContent().build();
        } catch (UsernameNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PreAuthorize("isAuthenticated() and (hasRole('ADMIN') or @authService.isSameUser(#username)) ")
    @PostMapping("/auth")
    public ResponseEntity<UserDTO> getUserDTOByUsername(@RequestBody String username) {
        try {
            // Llamar al servicio para obtener los detalles del usuario basado en el nombre de usuario
            return ResponseEntity.ok(UserMapper.INSTANCE.toUserDTO(userService.findByUsername(username)));
        } catch (UsernameNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }
}




