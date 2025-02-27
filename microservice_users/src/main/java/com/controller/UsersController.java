package com.controller;

import com.model.User;
import com.model.UserDTO;
import com.service.UserServiceCmdImpl;
import com.util.UserMapper;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;

@RestController
@RequestMapping("/users")
@AllArgsConstructor
public class UsersController {

    private final UserServiceCmdImpl userService;

    @GetMapping
    @PreAuthorize("@userServiceCmdImpl.isAdmin()")
    public ResponseEntity<List<User>> getAllUsers() {
        List<User> users = userService.findAll();
        return ResponseEntity.ok(users);
    }

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(userService.findById(id));
        } catch (EntityNotFoundException nfe) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping
    @PreAuthorize("@userServiceCmdImpl.isAdmin()")
    public ResponseEntity<User> createUser(@Valid @RequestBody User user) {
        User createdUser = userService.save(user);
        return ResponseEntity.created(UriComponentsBuilder.fromPath("/users/{id}")
                        .buildAndExpand(createdUser.getId())
                        .toUri())
                .body(createdUser);
    }

    @PutMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<User> updateUser(@Valid @RequestBody User user) {
        try {
            return ResponseEntity.ok(userService.update(user));
        } catch (EntityNotFoundException nfe) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("@userServiceCmdImpl.isAdmin()")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        try {

            userService.deleteById(id);
            return ResponseEntity.noContent().build();
        } catch (EntityNotFoundException nfe) {
            return ResponseEntity.notFound().build();
        }
    }


    @GetMapping("/auth")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<UserDTO> getUserDTOByUsername(@RequestParam String username) {
        try {
            return ResponseEntity.ok(UserMapper.INSTANCE.userToUserDTO(userService.findByUsername(username)));
        } catch (EntityNotFoundException nfe) {
            return ResponseEntity.notFound().build();
        }
    }
}



