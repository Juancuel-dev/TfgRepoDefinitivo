package com.service;

import com.model.Game;

import org.springframework.data.crossstore.ChangeSetPersister.NotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface GamesServiceCmd {

    // Obtener todos los juegos
    List<Game> findAll();

    // Buscar un juego por su ID
    Game findById(String id) throws NotFoundException;

    // Guardar un juego (crear o actualizar)
    Game save(Game game);
    // Actualizar un juego
    Game update(Game game);

    // Comprobar si un juego existe por su ID
    boolean existsById(String id) throws NotFoundException;

    void deleteById(String id) throws NotFoundException;
}