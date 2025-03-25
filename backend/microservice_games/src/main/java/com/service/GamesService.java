package com.service;

import com.util.exception.GameNotFoundException;
import com.util.exception.UnauthorizedException;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import com.model.Game;
import com.repository.GamesRepository;

import java.util.List;

@Service
public class GamesService{

    private final GamesRepository gamesRepository;

    // Constructor de inyección de dependencias
    public GamesService(GamesRepository gamesRepository) {
        this.gamesRepository = gamesRepository;
    }

    // Obtener todos los juegos
    public List<Game> findAll() {
            return gamesRepository.findAll();
        }


    // Buscar un juego por su ID
    public Game findById(String id) throws GameNotFoundException {
        return gamesRepository.findById(id)
                .orElseThrow(EntityNotFoundException::new);
    }

    // Guardar un juego (crear)
    public Game save(Jwt jwt,Game game) throws UnauthorizedException{
        if (jwt.getClaim("role").equals("ADMIN")) {
            return gamesRepository.save(game);
        }
        throw new UnauthorizedException("No estas autorizado para realizar esta accion");
    }


    // Guardar un juego (actualizar)
    public Game edit(Jwt jwt,Game game) throws UnauthorizedException, GameNotFoundException {
        if(jwt.getClaim("role").equals("ADMIN")) {
            if(gamesRepository.existsById(game.getId())) {

                return gamesRepository.save(game);
            }throw new GameNotFoundException("El juego no existe");
        }
        throw new UnauthorizedException("No estas autorizado para realizar esta accion.");
    }

    // Guardar un juego (crear o actualizar)
    public List<Game> saveAll(Jwt jwt,List<Game> games) throws UnauthorizedException {
        if(jwt.getClaim("role").equals("ADMIN")) {

            return gamesRepository.saveAll(games);
        }
        throw new UnauthorizedException("No estas autorizado para realizar esta accion.");

    }

    // Eliminar un juego por su ID
    public void deleteById(Jwt jwt,String id) throws GameNotFoundException, UnauthorizedException {
        if(jwt.getClaim("role").equals("ADMIN")) {

            if (!gamesRepository.existsById(id)) {
                throw new GameNotFoundException("Juego no encontrado.");
            }
            gamesRepository.deleteById(id);
        }else {
            throw new UnauthorizedException("No estas autorizado para realizar esta accion.");
        }
        }
}