package com.service;

import com.util.exception.GameNotFoundException;
import com.util.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import com.model.Game;
import com.repository.GamesRepository;

import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class GamesService{

    private final GamesRepository gamesRepository;

    private final FetchGamesService fetchGamesService;

    // Obtener todos los juegos
    public List<Game> findAll() {
            return gamesRepository.findAll();


        }
    // Obtener todos los juegos con limite
    public List<Game> findAllLimit(String limit) {

        int limitNumber = Integer.parseInt(limit);
        List<Game> games = new ArrayList<>();
        PageRequest pageRequest = PageRequest.of(0, limitNumber);
        gamesRepository.findAll(pageRequest).forEach(games::add);
        return games;
    }

        // Obtener todos los juegos por categoria
    public List<Game> findAllByConsola(String consola) {
            return gamesRepository.findAllByConsola(consola);
        }


    // Buscar un juego por su ID
    public Game findById(String id) throws GameNotFoundException {
        return gamesRepository.findById(id)
                .orElseThrow(()->new GameNotFoundException("Juego " + id + " no encontrado"));

    }// Buscar un juego por su nombre
    public Game findByName(String name) throws GameNotFoundException {
        name = name.replaceAll("-"," ");
        return (Game) gamesRepository.findByName(name)
                .orElseThrow(()->new GameNotFoundException("Juego no encontrado"));
    }

    public List<Game> searchGamesByName(String name) {
        log.info("Iniciando búsqueda para: '{}'", name);

        if (name == null || name.trim().isEmpty()) {
            return new ArrayList<>();
        }

        // Normalización del input
        String normalizedInput = normalizeInput(name);
        String[] searchTerms = normalizedInput.split(" ");

        // 1. Búsqueda exacta (frase completa)
        List<Game> exactResults = searchExactPhrase(normalizedInput);
        if (!exactResults.isEmpty()) {
            return exactResults;
        }

        // 2. Búsqueda de todos los términos exactos
        List<Game> allTermsResults = searchAllTerms(searchTerms);
        if (!allTermsResults.isEmpty()) {
            return sortByRelevance(allTermsResults, normalizedInput, searchTerms);
        }

        // 3. Búsqueda aproximada (tolerancia a errores)
        return fuzzySearchWithScoring(normalizedInput, searchTerms);
    }

    private List<Game> fuzzySearchWithScoring(String fullQuery, String[] searchTerms) {
        // Obtenemos todos los juegos
        List<Game> allGames = gamesRepository.findAll();

        // Mapa temporal para almacenar puntuaciones
        Map<Game, Integer> gameScores = new HashMap<>();

        // Calculamos puntuaciones para cada juego
        for (Game game : allGames) {
            String gameName = game.getName().toLowerCase();
            int score = calculateFuzzyMatchScore(gameName, fullQuery, searchTerms);

            if (score > 50) { // Umbral mínimo de aceptación
                gameScores.put(game, score);
            }
        }

        // Ordenamos por puntuación descendente
        return gameScores.entrySet().stream()
                .sorted(Map.Entry.<Game, Integer>comparingByValue().reversed())
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
    }

    private int calculateFuzzyMatchScore(String gameName, String fullQuery, String[] searchTerms) {
        int score = 0;

        // 1. Coincidencia con la frase completa
        int fullQueryScore = calculateFuzzyScore(gameName, fullQuery);
        score += fullQueryScore;

        // 2. Coincidencia con términos individuales
        for (String term : searchTerms) {
            score += (int) (calculateFuzzyScore(gameName, term) * 0.7); // Peso menor que la frase completa
        }

        // 3. Bonus si los términos aparecen en orden
        if (searchTerms.length > 1) {
            if (termsAppearInOrder(gameName, searchTerms)) {
                score += 30;
            }
        }

        return score;
    }

    private boolean termsAppearInOrder(String text, String[] terms) {
        int lastIndex = -1;
        for (String term : terms) {
            int currentIndex = text.indexOf(term);
            if (currentIndex == -1) {
                return false;
            }
            if (currentIndex < lastIndex) {
                return false;
            }
            lastIndex = currentIndex;
        }
        return true;
    }

    private String normalizeInput(String input) {
        return input.trim().toLowerCase()
                .replace("%20", " ");
    }

    private List<Game> searchExactPhrase(String phrase) {
        String exactPhraseRegex = "(?i)^" + Pattern.quote(phrase) + ".*";
        List<Game> results = gamesRepository.findByNameRegex(exactPhraseRegex);

        if (results.isEmpty()) {
            exactPhraseRegex = "(?i).*" + Pattern.quote(phrase) + ".*";
            results = gamesRepository.findByNameRegex(exactPhraseRegex);
        }

        return results;
    }

    private List<Game> searchAllTerms(String[] terms) {
        if (terms.length == 0) return new ArrayList<>();

        String regex = "(?i)(?=.*" + String.join(")(?=.*", terms) + ").*";
        return gamesRepository.findByNameRegex(regex);
    }

    private int calculateFuzzyScore(String text, String query) {
        // Coincidencia exacta
        if (text.contains(query)) {
            return 100;
        }

        // Algoritmo de similitud aproximada (Levenshtein modificado)
        int maxDistance = Math.max(1, query.length() / 3);
        int distance = levenshteinDistance(text, query);

        if (distance <= maxDistance) {
            return 100 - (distance * 100 / maxDistance);
        }

        // Buscar subcadenas aproximadas
        int bestScore = 0;
        for (int i = 0; i <= text.length() - query.length(); i++) {
            String substring = text.substring(i, i + query.length());
            distance = levenshteinDistance(substring, query);
            if (distance <= maxDistance) {
                int currentScore = 100 - (distance * 100 / maxDistance);
                if (currentScore > bestScore) {
                    bestScore = currentScore;
                }
            }
        }

        return bestScore;
    }

    // Algoritmo de distancia de Levenshtein para medir diferencias entre strings
    private int levenshteinDistance(String a, String b) {
        a = a.toLowerCase();
        b = b.toLowerCase();

        int[] costs = new int[b.length() + 1];
        for (int j = 0; j < costs.length; j++) {
            costs[j] = j;
        }

        for (int i = 1; i <= a.length(); i++) {
            costs[0] = i;
            int nw = i - 1;
            for (int j = 1; j <= b.length(); j++) {
                int cj = Math.min(1 + Math.min(costs[j], costs[j - 1]),
                        a.charAt(i - 1) == b.charAt(j - 1) ? nw : nw + 1);
                nw = costs[j];
                costs[j] = cj;
            }
        }

        return costs[b.length()];
    }

    private List<Game> sortByRelevance(List<Game> games, String fullQuery, String[] searchTerms) {
        games.sort((g1, g2) -> {

            // Lógica de ordenación original para búsquedas no aproximadas
            int score1 = calculateRelevanceScore(g1.getName(), fullQuery, searchTerms);
            int score2 = calculateRelevanceScore(g2.getName(), fullQuery, searchTerms);

            if (score1 == score2) {
                return Integer.compare(g1.getName().length(), g2.getName().length());
            }

            return Integer.compare(score2, score1);
        });

        return games;
    }

    private int calculateRelevanceScore(String gameName, String fullQuery, String[] searchTerms) {
        String lowerName = gameName.toLowerCase();
        int score = 0;

        // 1. Coincidencia exacta desde el inicio (máxima prioridad)
        if (lowerName.startsWith(fullQuery)) {
            score += 1000;
        }

        // 2. Todos los términos presentes en orden (aunque no consecutivos)
        boolean allTermsInOrder = true;
        int lastIndex = -1;
        for (String term : searchTerms) {
            int currentIndex = lowerName.indexOf(term);
            if (currentIndex == -1) {
                allTermsInOrder = false;
                break;
            }
            if (currentIndex < lastIndex) {
                allTermsInOrder = false;
                break;
            }
            lastIndex = currentIndex;
        }
        if (allTermsInOrder) {
            score += 800;
        }

        // 3. Todos los términos presentes (sin importar orden)
        boolean allTermsPresent = true;
        for (String term : searchTerms) {
            if (!lowerName.contains(term)) {
                allTermsPresent = false;
                break;
            }
        }
        if (allTermsPresent) {
            score += 500;
        }

        // 4. Puntos por cada término individual
        for (String term : searchTerms) {
            if (lowerName.contains(term)) {
                score += 100;

                // Bonus si el término está al inicio
                if (lowerName.startsWith(term)) {
                    score += 50;
                }

                // Bonus si el término es largo (más significativo)
                if (term.length() >= 5) {
                    score += term.length() * 2;
                }
            }
        }

        // 5. Coincidencia exacta en cualquier posición
        if (lowerName.contains(fullQuery)) {
            score += 200;
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