package tfg.controller;

import org.springframework.data.crossstore.ChangeSetPersister.NotFoundException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import tfg.model.Game;
import tfg.service.GamesServiceCmdImpl;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/games")
public class GamesController {

    private final GamesServiceCmdImpl gamesService;

    // Constructor de inyección de dependencias
    public GamesController(GamesServiceCmdImpl gamesService) {
        this.gamesService = gamesService;
    }

    // Obtener todos los juegos
    @GetMapping
    public ResponseEntity<List<Game>> findAll() {
        return ResponseEntity.ok(gamesService.findAll());
    }

    // Obtener un juego por id
    @GetMapping("/{id}")
    public ResponseEntity<Game> findById(@PathVariable String id) throws NotFoundException {
        return ResponseEntity.ok(gamesService.findById(id));
    }

    // Crear un nuevo juego
    @PostMapping
    public ResponseEntity<Game> save(@RequestBody Game game) {
        Game savedGame = gamesService.save(game);
        // Retornar 201 Created con la URL del nuevo recurso
        if (savedGame.getId() == null) {
            throw new RuntimeException("No se pudo obtener la URL del recurso creado");
        }
        URI uri = UriComponentsBuilder.fromPath("/games/{id}")
                .buildAndExpand(savedGame.getId())
                .toUri();
        return ResponseEntity.created(uri).body(savedGame); // Idealmente, deberías incluir la URL del recurso creado.
    }

    // Crear un nuevo juego
    @PostMapping("/all")
    public ResponseEntity<List<Game>> saveAll(@RequestBody List<Game> games) {
        List<Game> savedGames = gamesService.saveAll(games);
        // Retornar 201 Created con la URL del nuevo recurso
        if (savedGames.get(1).getId() == null) {
            throw new RuntimeException("No se pudo obtener la URL del recurso creado");
        }
        URI uri = UriComponentsBuilder.fromPath("/games/{id}")
                .buildAndExpand(savedGames.hashCode())
                .toUri();
        return ResponseEntity.created(uri).body(savedGames); // Idealmente, deberías incluir la URL del recurso creado.
    }

    // Actualizar un juego existente
    @PutMapping("/{id}")
    public ResponseEntity<Game> update(@PathVariable String id, @RequestBody Game game) {
        game.setId(id);  // Aseguramos que el ID del juego está presente en la solicitud
        try {
            Game updatedGame = gamesService.update(game);
            return ResponseEntity.ok(updatedGame);  // Retornamos el juego actualizado
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();  // Retornamos 404 Not Found si el juego no existe
        }
    }

    // Eliminar un juego
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable String id) {
        try {
            gamesService.deleteById(id);  // Llamamos al servicio para eliminar el juego
            return ResponseEntity.noContent().build();
        } catch (NotFoundException nfe) {
            return ResponseEntity.notFound().build();
        }
    }
}
