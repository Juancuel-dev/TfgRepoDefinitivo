package com.service;

import com.model.User;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface UserServiceCmd {

    // Obtener todos los usuarios
    List<User> findAll();

    // Buscar un usuario por su ID
    User findById(String id) throws UsernameNotFoundException;
    // Buscar un usuario por su username
    User findByUsername(String username) throws UsernameNotFoundException;

    // Guardar un usuario (crear o actualizar)
    User save(User User) throws Exception;

    // Comprobar si un usuario existe por su ID
    boolean existsById(String id);

    void deleteById(String id) throws UsernameNotFoundException;

}