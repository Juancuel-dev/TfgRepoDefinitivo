package com.service;

import com.util.exception.GameNotFoundException;
import com.util.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import com.model.Game;
import com.repository.GamesRepository;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class GamesService{

    private final GamesRepository gamesRepository;

    private final FetchGamesService fetchGamesService;

    // Obtener todos los juegos
    public List<Game> findAll() {
            return gamesRepository.findAll();


        }// Obtener todos los juegos por categoria
    public List<Game> findAllByConsola(String consola) {
            return gamesRepository.findAllByConsola(consola);
        }


    // Buscar un juego por su ID
    public Game findById(String id) throws GameNotFoundException {
        return gamesRepository.findById(id)
                .orElseThrow(()->new GameNotFoundException("Juego " + id + " no encontrado"));
    }

    public List<Game> searchGamesByName(String name) {
        if(name == null || name.isEmpty()){
            return new ArrayList<>();
        }
        // Crear una expresión regular para buscar nombres que contengan el término (insensible a mayúsculas)
        String regex = "(?i).*" + name + ".*"; // (?i) hace que la búsqueda sea insensible a mayúsculas
        return gamesRepository.findByNameRegex(regex);
    }

    public List<Game> fetchGamesAPI(String page) {

        return gamesRepository.saveAll(fetchGamesService.fetchGamesAPI(page));
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