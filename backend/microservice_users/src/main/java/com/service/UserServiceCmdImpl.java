package com.service;

import com.model.User;
import com.repository.UserRepository;
import com.util.Role;
import jakarta.persistence.EntityNotFoundException;
import lombok.AllArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class UserServiceCmdImpl implements UserServiceCmd {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // Obtener todos los users
    public List<User> findAll() {
        return userRepository.findAll();
    }

    // Buscar un user por su ID
    public User findById(Long id) throws EntityNotFoundException {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null
                || !authentication.isAuthenticated()
                || !authentication.getAuthorities().contains(new SimpleGrantedAuthority(Role.ADMIN.name()))) {
            throw new RuntimeException("No estás autenticado");
        }
        return userRepository.findById(id)
                .orElseThrow(EntityNotFoundException::new);
    }

    @Override
    public User findByUsername(String username) throws EntityNotFoundException {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null
                || !authentication.isAuthenticated()
                || !authentication.getPrincipal().equals(username)
                || !authentication.getAuthorities().contains(new SimpleGrantedAuthority(Role.ADMIN.name()))) {
            throw new RuntimeException("No estás autenticado");
        }
        return userRepository.findByUsername(username)
                .orElseThrow(EntityNotFoundException::new);
    }

    // Guardar un user (crear o actualizar)
    public User save(User user) {
        String encryptedPassword = passwordEncoder.encode(user.getPassword());
        user.setPassword(encryptedPassword);
        return userRepository.save(user);
    }

    // Comprobar si un user existe por su ID
    public boolean existsById(Long id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null
                || !authentication.isAuthenticated()
                || !authentication.getAuthorities().contains(new SimpleGrantedAuthority(Role.ADMIN.name()))) {
            throw new RuntimeException("No estás autenticado");
        }
        return userRepository.existsById(id);

    }

    // Eliminar un user por su ID
    public void deleteById(Long id) throws EntityNotFoundException{

        if (!userRepository.existsById(id)) {
            throw new EntityNotFoundException();
        }
        userRepository.deleteById(id);
    }


}