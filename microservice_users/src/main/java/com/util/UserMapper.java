package com.util;


import com.model.User;
import com.model.UserDTO;
import org.mapstruct.factory.Mappers;

@org.mapstruct.Mapper
public interface UserMapper {

    UserMapper INSTANCE = Mappers.getMapper( UserMapper.class );
    UserDTO userToUserDTO(User user);
}


