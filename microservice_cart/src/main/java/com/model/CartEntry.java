package com.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "cart_entry")
public class CartEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long gameId;

    @Column(nullable = false)
    private Long customerId;

    @Column(nullable = false)
    private Integer quantity;

    public CartEntry(CartEntryDTO cartEntryDTO) {
        this.gameId = cartEntryDTO.getGameId();
        this.customerId = cartEntryDTO.getCustomerId();
        this.quantity = cartEntryDTO.getQuantity();
    }

}
