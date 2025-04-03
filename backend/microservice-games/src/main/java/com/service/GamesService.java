package com.service;

import com.model.GameDTO;
import com.util.exception.GameNotFoundException;
import com.util.exception.UnauthorizedException;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import com.model.Game;
import com.repository.GamesRepository;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.util.List;
import java.util.Map;

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
                .orElseThrow(EntityNotFoundException::new);
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