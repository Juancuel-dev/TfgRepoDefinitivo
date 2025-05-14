package com.service;

import com.util.exception.GameNotFoundException;
import com.util.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import com.model.Game;
import com.repository.GamesRepository;

import java.util.*;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
@Slf4j
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
        log.info("Iniciando búsqueda para: '{}'", name);

        if (name == null || name.trim().isEmpty()) {
            return new ArrayList<>();
        }

        String normalizedInput = name.trim().toLowerCase();
        String[] searchTerms = normalizedInput.split("%20");

        // 1. Primero buscar la frase exacta
        String exactPhraseRegex = "(?i).*" + Pattern.quote(normalizedInput) + ".*";
        List<Game> exactResults = gamesRepository.findByNameRegex(exactPhraseRegex);

        if (!exactResults.isEmpty()) {
            log.info("Encontrados {} resultados para frase exacta", exactResults.size());
            return exactResults;
        }

        log.debug("No se encontraron resultados para frase exacta, buscando términos individuales");

        // 2. Búsqueda por términos individuales
        Set<Game> combinedResults = new HashSet<>();

        for (String term : searchTerms) {
            String termRegex = "(?i).*" + Pattern.quote(term) + ".*";
            List<Game> termResults = gamesRepository.findByNameRegex(termRegex);
            combinedResults.addAll(termResults);
        }

        // 3. Ordenar por relevancia
        List<Game> finalResults = new ArrayList<>(combinedResults);
        finalResults.sort((g1, g2) -> {
            int score1 = calculateRelevanceScore(g1.getName(), normalizedInput, searchTerms);
            int score2 = calculateRelevanceScore(g2.getName(), normalizedInput, searchTerms);
            return Integer.compare(score2, score1);
        });

        log.info("Búsqueda completada. {} resultados encontrados", finalResults.size());
        return finalResults;
    }

    private int calculateRelevanceScore(String gameName, String fullQuery, String[] searchTerms) {
        String lowerName = gameName.toLowerCase();
        int score = 0;

        // Priorizar coincidencias con el inicio del nombre
        if (lowerName.startsWith(fullQuery)) {
            score += 100;
        }

        // Puntos por cada término coincidente
        for (String term : searchTerms) {
            if (lowerName.contains(term)) {
                score += 10;

                // Bonus si el término está al inicio
                if (lowerName.startsWith(term)) {
                    score += 5;
                }
            }
        }

        // Bonus por coincidencia exacta de múltiples términos en orden
        if (lowerName.contains(fullQuery)) {
            score += 30;
        }

        return score;
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