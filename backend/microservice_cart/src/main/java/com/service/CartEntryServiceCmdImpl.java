package com.service;

import com.model.CartEntry;
import com.model.CartEntryDTO;
import com.model.GameDTO;
import com.repository.CartEntryRepository;
import com.util.CartEntryMapper;
import com.util.Constantes;
import jakarta.persistence.EntityNotFoundException;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
public class CartEntryServiceCmdImpl implements CartEntryServiceCmd {

    private final CartEntryRepository repository;

    @Override
    public List<CartEntryDTO> findByCustomerIdDTO(Long customerId) {
        List<CartEntry> entries = repository.findByCustomerId(customerId);
        if (entries.isEmpty()) {
            throw new EntityNotFoundException("No se encontraron entradas para el cliente: " + customerId);
        }
        return entries.stream()
                .map(CartEntryMapper.INSTANCE::cartEntryToCartEntryDTO)
                .collect(Collectors.toList());
    }

    @Override
    public void clear(Long customerId) {
        List<CartEntry> entries = repository.findByCustomerId(customerId);
        if (entries.isEmpty()) {
            throw new EntityNotFoundException("No se encontraron entradas para eliminar del cliente: " + customerId);
        }
        repository.deleteAll(entries);
    }

    @Override
    public CartEntryDTO save(CartEntryDTO cartEntry) {

        return CartEntryMapper.INSTANCE.cartEntryToCartEntryDTO(repository.save(new CartEntry(cartEntry)));
    }

    @Override
    public List<CartEntryDTO> findAll() {
        return repository.findAll().stream()
                .map(CartEntryMapper.INSTANCE::cartEntryToCartEntryDTO)
                .collect(Collectors.toList());
    }

    @Override
    public CartEntryDTO addUnits(Long customerId, Long gameId, Integer quantity) throws EntityNotFoundException{
        CartEntry entry = repository.findByCustomerIdAndGameId(customerId, gameId)
                .orElseThrow(() -> new EntityNotFoundException("No se encontró el game en el carrito"));

        entry.setQuantity(entry.getQuantity() + quantity);
        return CartEntryMapper.INSTANCE.cartEntryToCartEntryDTO(repository.save(entry));
    }

    @Override
    public void deleteById(Long id) {
        repository.deleteById(id);
    }

    @Override
    public Long getIdByCartEntry(CartEntryDTO cartEntry) {
        return repository.findByCustomerIdAndGameId(cartEntry.getCustomerId(), cartEntry.getGameId())
                .orElseThrow(() -> new EntityNotFoundException("No se encontró la entrada del carrito"))
                .getId();
    }

    @Override
    public List<GameDTO> cartDetails(Long customerId) throws EntityNotFoundException {

        RestTemplate restTemplate = new RestTemplate();
        return this.findByCustomerIdDTO(customerId).stream()
                .map(entry -> restTemplate.getForObject(Constantes.BASE_URL_GAMES + "/" + entry.getGameId(), GameDTO.class))
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }

    @Override
    public Float finalPrice(Long customerId) throws EntityNotFoundException {
        return cartDetails(customerId).stream()
                .map(GameDTO::getPrecio)
                .reduce(0F, Float::sum);
    }
}
