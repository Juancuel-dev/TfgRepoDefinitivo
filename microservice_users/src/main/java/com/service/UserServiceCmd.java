package com.service;

import com.model.User;
import org.springframework.data.crossstore.ChangeSetPersister.NotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface UserServiceCmd {

    // Obtener todos los usuarios
    List<User> findAll();

    // Buscar un usuario por su ID
    User findById(Long id) throws NotFoundException;
    // Buscar un usuario por su username
    User findByUsername(String username) throws NotFoundException;

    // Guardar un usuario (crear o actualizar)
    User save(User User);
    // Actualizar un usuario
    User update(User User) throws NotFoundException;

    // Comprobar si un usuario existe por su ID
    boolean existsById(Long id);

    void deleteById(Long id) throws NotFoundException;

    boolean isAdmin();
}