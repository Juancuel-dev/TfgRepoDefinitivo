package com.service;

import com.model.User;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface UserServiceCmd {

    // Obtener todos los usuarios
    List<User> findAll();

    // Buscar un usuario por su ID
    User findById(Long id) throws EntityNotFoundException;
    // Buscar un usuario por su username
    User findByUsername(String username) throws EntityNotFoundException;

    // Guardar un usuario (crear o actualizar)
    User save(User User);

    // Comprobar si un usuario existe por su ID
    boolean existsById(Long id);

    void deleteById(Long id) throws EntityNotFoundException;

}