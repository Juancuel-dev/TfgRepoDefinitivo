package com.controller;

import com.model.CartEntryDTO;
import com.model.GameDTO;
import com.service.CartEntryServiceCmd;
import jakarta.persistence.EntityNotFoundException;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@AllArgsConstructor
@RequestMapping("/cart")
public class CartEntryController {

    private CartEntryServiceCmd service;

    @GetMapping("/all")
    public ResponseEntity<List<CartEntryDTO>> getAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/{customerId}")
    public ResponseEntity<List<CartEntryDTO>> getAllByCustomerId(@PathVariable("customerId") Long customerId) {
        try{
            return ResponseEntity.ok(service.findByCustomerIdDTO(customerId));
        }catch(EntityNotFoundException nfe){
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{customerId}/details")
    public ResponseEntity<List<GameDTO>> getDetails(@PathVariable("customerId") Long customerId) {
        try{
            return ResponseEntity.ok(service.cartDetails(customerId));
        }catch(EntityNotFoundException nfe){
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping
    public CartEntryDTO addToCart(@RequestBody CartEntryDTO cartEntryDTO){
        return service.save(cartEntryDTO);
    }

    @PatchMapping("/{customerId}/{productId}")
    public CartEntryDTO addProductUnits(@PathVariable("customerId") Long customerId, @PathVariable("productId") Long productId, @RequestParam Integer quantity){
        return service.addUnits(customerId,productId,quantity);
    }

    @DeleteMapping
    public void removeFromCart(@RequestBody CartEntryDTO cartEntryDTO){
        service.deleteById(service.getIdByCartEntry(cartEntryDTO));
    }

    @DeleteMapping("/{customerId}")
    public void clearCart(@PathVariable Long customerId){
        service.clear(customerId);
    }
}
