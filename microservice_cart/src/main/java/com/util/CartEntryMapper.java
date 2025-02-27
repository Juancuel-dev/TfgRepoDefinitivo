package com.util;

import com.model.CartEntry;
import com.model.CartEntryDTO;
import org.mapstruct.factory.Mappers;

@org.mapstruct.Mapper
public interface CartEntryMapper {

    CartEntryMapper INSTANCE = Mappers.getMapper(CartEntryMapper.class);
    CartEntryDTO cartEntryToCartEntryDTO(CartEntry game);
}


