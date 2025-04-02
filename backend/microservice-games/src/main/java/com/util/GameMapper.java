package com.util;

import org.mapstruct.factory.Mappers;
import com.model.Game;
import com.model.GameDTO;

@org.mapstruct.Mapper
public interface GameMapper {

    GameMapper INSTANCE = Mappers.getMapper(GameMapper.class);
    GameDTO gameToGameDTO(Game game);
}


