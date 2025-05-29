package com.controller;

import com.model.Game;
import com.service.GamesService;
import com.util.exception.GameNotFoundException;
import com.util.exception.UnauthorizedException;
import jakarta.ws.rs.QueryParam;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/games")
@RequiredArgsConstructor
public class GamesController {

    private final GamesService gamesService;

    @GetMapping
    public ResponseEntity<List<Game>> findAll() {
            return ResponseEntity.ok(gamesService.findAll());
    }

    @GetMapping("/limit")
    public ResponseEntity<List<Game>> findAllLimit(@QueryParam("limit")String limit) {
            return ResponseEntity.ok(gamesService.findAllLimit(limit));
    }

    @GetMapping("/consola/{consola}")
    public ResponseEntity<List<Game>> findAllByConsola(@PathVariable String consola) {
            return ResponseEntity.ok(gamesService.findAllByConsola(consola));
    }

    @GetMapping("/fetchgames/{page}")
    public ResponseEntity<List<Game>> fetchGames(@PathVariable String page) {
            return ResponseEntity.ok(gamesService.fetchGamesAPI(page));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Game> findById(@PathVariable String id) {
        try{
            return ResponseEntity.ok(gamesService.findById(id));
        }catch(GameNotFoundException gnfe){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @GetMapping("/name/{name}")
    public ResponseEntity<Game> findByName(@PathVariable String name) {
        try{
            return ResponseEntity.ok(gamesService.findByName(name));
        }catch(GameNotFoundException gnfe){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @GetMapping("/search")
    public ResponseEntity<List<Game>> search(@RequestParam String name) {
        return ResponseEntity.ok(gamesService.searchGamesByName(name));
    }

    @PostMapping("/update")
    public ResponseEntity<Game> updateGame(@AuthenticationPrincipal Jwt jwt,Game Game){
        try{
            return ResponseEntity.ok(gamesService.edit(jwt,Game));
        }catch(UnauthorizedException ue){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }catch(GameNotFoundException gnfe){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @PostMapping
    public ResponseEntity<Game> save(@AuthenticationPrincipal Jwt jwt,@RequestBody Game Game) {
        try{
            Game savedGame = gamesService.save(jwt,Game);
        return ResponseEntity.created(URI.create("/Games/" + savedGame.getId()))
                .body(savedGame);

        }catch(UnauthorizedException ue){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteById(@AuthenticationPrincipal Jwt jwt, @PathVariable String id) {
        try{
            gamesService.deleteById(jwt,id);
            return ResponseEntity.noContent().build();
        }catch(UnauthorizedException ue){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }catch(GameNotFoundException gnfe){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }
}