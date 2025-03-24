package com.controller;

import com.model.User;
import com.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping
@RequiredArgsConstructor
public class UsersController {

    private final UserService userService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Mono<ResponseEntity<List<User>>> findAll(ServerWebExchange exchange) {
        String token = exchange.getRequest().getHeaders().getFirst("Authorization");
        return Mono.fromCallable(() -> ResponseEntity.ok(userService.findAll()))
                .subscribeOn(Schedulers.boundedElastic());
    }

    @GetMapping("/{id}")
    public Mono<ResponseEntity<User>> findById(ServerWebExchange exchange, @PathVariable String id) {
        String token = exchange.getRequest().getHeaders().getFirst("Authorization");
        return Mono.fromCallable(() -> ResponseEntity.ok(userService.findById(id)))
                .subscribeOn(Schedulers.boundedElastic());
    }

    @GetMapping("/username/{username}")
    public Mono<ResponseEntity<User>> findByUsername(ServerWebExchange exchange, @PathVariable String username) {
        String token = exchange.getRequest().getHeaders().getFirst("Authorization");
        return Mono.fromCallable(() -> ResponseEntity.ok(userService.findByUsername( username)))
                .subscribeOn(Schedulers.boundedElastic());
    }

    @PostMapping("/register")
    public Mono<ResponseEntity<User>> save(ServerWebExchange exchange) {
        return exchange.getFormData()
                .flatMap(formData -> {
                    String token = exchange.getRequest().getHeaders().getFirst("Authorization");
                    User user = new User();
                    // Asignar valores del formData al usuario
                    return Mono.fromCallable(() ->
                            ResponseEntity.created(URI.create("/"))
                                    .body(userService.save(user))
                    ).subscribeOn(Schedulers.boundedElastic());
                });
    }

    @DeleteMapping("/{id}")
    public Mono<ResponseEntity<Object>> deleteById(@PathVariable String id) {
        return Mono.fromCallable(() -> {
                    userService.deleteById(id);
                    return ResponseEntity.<Void>noContent().build();
                })
                .onErrorResume(UsernameNotFoundException.class, e ->
                        Mono.just(ResponseEntity.<Void>notFound().build()))
                .onErrorResume(Exception.class, e ->
                        Mono.just(ResponseEntity.<Void>internalServerError().build()))
                .subscribeOn(Schedulers.boundedElastic());
    }
}