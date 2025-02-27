package com.service;

import com.model.Game;

import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface GamesServiceCmd {

    // Obtener todos los juegos
    List<Game> findAll();

    // Buscar un juego por su ID
    Game findById(String id) throws EntityNotFoundException;

    // Guardar un juego (crear o actualizar)
    Game save(Game game);
    // Actualizar un juego
    Game update(Game game);

    // Comprobar si un juego existe por su ID
    boolean existsById(String id) throws EntityNotFoundException;

    void deleteById(String id) throws EntityNotFoundException;
}