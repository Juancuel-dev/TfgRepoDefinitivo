package com.service;

import com.model.CartEntryDTO;
import com.repository.CartEntryDTORepository;
import com.util.CartEntryMapper;
import lombok.AllArgsConstructor;
import org.springframework.data.crossstore.ChangeSetPersister;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
public class CartEntryDTOService {

    private CartEntryDTORepository cartEntryDTORepository;

    public List<CartEntryDTO> getCartEntryDTO(Long costumerId) throws ChangeSetPersister.NotFoundException {
        return cartEntryDTORepository
                .findByCustomerId(costumerId)
                .orElseThrow(ChangeSetPersister.NotFoundException::new)
                .stream()
                .map(CartEntryMapper.INSTANCE::cartEntryToCartEntryDTO)
                .collect(Collectors.toList());
    }
}
