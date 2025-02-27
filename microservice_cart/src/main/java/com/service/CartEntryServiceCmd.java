package com.service;

import com.model.CartEntryDTO;
import com.model.GameDTO;
import jakarta.persistence.EntityNotFoundException;

import java.util.List;

public interface CartEntryServiceCmd {

    List<CartEntryDTO> findByCustomerIdDTO(Long customerId) throws EntityNotFoundException;

    void clear(Long customerId) throws EntityNotFoundException;

    CartEntryDTO save(CartEntryDTO cartEntry);

    List<CartEntryDTO> findAll();

    CartEntryDTO addUnits(Long customerId,Long gameId, Integer quantity) throws EntityNotFoundException;

    void deleteById(Long id);

    Long getIdByCartEntry(CartEntryDTO cartEntry) throws EntityNotFoundException;

    List<GameDTO> cartDetails(Long customerId) throws EntityNotFoundException;

    Float finalPrice(Long customerId) throws EntityNotFoundException;
}
