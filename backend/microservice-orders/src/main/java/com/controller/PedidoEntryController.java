package com.controller;

import com.model.CartItem;
import com.model.PedidoEntry;
import com.service.PedidoEntryService;
import com.util.exception.*;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/orders")
@RequiredArgsConstructor
public class PedidoEntryController {

    private final PedidoEntryService service;

    @GetMapping
    public ResponseEntity<List<PedidoEntry>> findAll(@AuthenticationPrincipal Jwt jwt) {
        try {
            return ResponseEntity.ok(service.findAll(jwt));
        } catch (UnauthorizedException ue) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }
    @GetMapping("/date/{date}")
    public ResponseEntity<List<PedidoEntry>> findAllByDate(@AuthenticationPrincipal Jwt jwt, @PathVariable String date) {
        LocalDate localDate = LocalDate.parse(date);
        try {
            return ResponseEntity.ok(service.findAllByDate(jwt,localDate));
        } catch (UnauthorizedException ue) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @GetMapping("/games/{orderId}")
    public ResponseEntity<List<CartItem>> findGamesFromOrder(@AuthenticationPrincipal Jwt jwt, @PathVariable String orderId) {
        try{
            return ResponseEntity.ok(service.getJuegosFromOrder(jwt,orderId));
        }catch(PedidoEntryNotFoundException e){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @PostMapping
    public ResponseEntity<PedidoEntry> save(@AuthenticationPrincipal Jwt jwt, @RequestBody PedidoEntry entry) {
        try {
            return ResponseEntity.status(HttpStatus.CREATED).body(service.save(jwt, entry));
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        } catch (UnauthorizedException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @GetMapping("/order/{orderId}")
    public ResponseEntity<List<PedidoEntry>> findByOrderId(@AuthenticationPrincipal Jwt jwt, @PathVariable String orderId) {
        try {
            return ResponseEntity.ok(service.findAllByOrderId(jwt, orderId));
        } catch (OrderIdNotFoundException oinfe) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        } catch (UnauthorizedException ue) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<PedidoEntry>> findAllByUserId(@AuthenticationPrincipal Jwt jwt, @PathVariable String userId) {
        try {
            return ResponseEntity.ok(service.findAllByUserId(jwt, userId));
        } catch (UserIdNotFoundException oinfe) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        } catch (UnauthorizedException ue) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @GetMapping("/order/{orderId}/total")
    public ResponseEntity<Float> getTotalPrice(@AuthenticationPrincipal Jwt jwt, @PathVariable String orderId) {
        try{
            return ResponseEntity.ok(service.getTotalPrice(jwt,orderId));
        } catch (OrderIdNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        } catch (UnauthorizedException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @PostMapping("/all")
    public ResponseEntity<List<PedidoEntry>> saveAll(@AuthenticationPrincipal Jwt jwt, @RequestBody List<PedidoEntry> entry) {
        try {
            return ResponseEntity.ok(service.saveAll(jwt, entry));
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }catch (UnauthorizedException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @GetMapping("/most-purchased")
    public ResponseEntity<List<CartItem>> mostPurchasedGames(@AuthenticationPrincipal Jwt jwt) {
        try{
            return ResponseEntity.ok(service.mostPurchasedGames(jwt,5));
        }catch (UnauthorizedException ue){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }
}
