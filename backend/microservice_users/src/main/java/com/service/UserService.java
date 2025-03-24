package com.service;

import com.model.User;
import com.repository.UserRepository;
import com.util.Role;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // Obtener todos los usuarios
    public List<User> findAll() {
        return userRepository.findAll();
    }

    // Buscar un usuario por su ID
    public User findById(String id) throws UsernameNotFoundException {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null
                || !authentication.isAuthenticated()
                || !authentication.getAuthorities().contains(new SimpleGrantedAuthority(Role.ADMIN.name()))) {
            throw new RuntimeException("No estás autenticado");
        }
        return userRepository.findById(id)
                .orElseThrow(() -> new UsernameNotFoundException(id));
    }

    public User findByUsername(String username) throws UsernameNotFoundException {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null
                || !authentication.isAuthenticated()
                || !authentication.getPrincipal().equals(username)
                || !authentication.getAuthorities().contains(new SimpleGrantedAuthority(Role.ADMIN.name()))) {
            throw new RuntimeException("No estás autenticado");
        }
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException(username));
    }

    // Guardar un usuario (crear o actualizar)
    public User save(User user) throws Exception {
        String encryptedPassword = passwordEncoder.encode(user.getPassword());
        user.setPassword(encryptedPassword);
        return userRepository.save(user);
    }

    // Comprobar si un usuario existe por su ID
    public boolean existsById(String id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null
                || !authentication.isAuthenticated()
                || !authentication.getAuthorities().contains(new SimpleGrantedAuthority(Role.ADMIN.name()))) {
            throw new RuntimeException("No estás autenticado");
        }
        return userRepository.existsById(id);
    }

    // Eliminar un usuario por su ID
    public void deleteById(String id) throws UsernameNotFoundException {
        if (!userRepository.existsById(id)) {
            throw new UsernameNotFoundException("Usuario con id " + id + " no encontrado");
        }
        userRepository.deleteById(id);
    }
}