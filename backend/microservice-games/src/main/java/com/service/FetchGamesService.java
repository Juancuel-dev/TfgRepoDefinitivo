package com.service;

import com.model.Game;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class FetchGamesService {

    private final RestTemplate restTemplate;

    public List<Game> fetchGamesAPI(String page) {
        String url = "https://api.rawg.io/api/games?key=b03bf76ba2e34b86a86861557d922a55&page=" + page;

        // Realizar la solicitud GET
        Map<String, Object> response = restTemplate.getForObject(url, Map.class);

        // Extraer los resultados
        List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");

        // Mapear los resultados a GameDTO
        List<Game> games = new ArrayList<>();
        for (Map<String, Object> result : results) {
            Game game = new Game();
            game.setName((String) result.get("name"));
            game.setPrecio((float) (Math.random()*59+1)); // Valor predeterminado, ya que no está en la respuesta
            game.setMetacritic((Integer) result.get("metacritic"));
            game.setImagen((String) result.get("background_image"));

            // Extraer la primera consola de la lista de plataformas
            List<Map<String, Object>> platforms = (List<Map<String, Object>>) result.get("platforms");
            if (platforms != null && !platforms.isEmpty()) {
                Map<String, Object> platform = (Map<String, Object>) platforms.get(0).get("platform");
                game.setConsola((String) platform.get("name"));
            } else {
                game.setConsola("Desconocida");
            }

            games.add(game);
        }

        return games;
    }

}
