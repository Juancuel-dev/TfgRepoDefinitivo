package com.util;

import com.model.register.RegisterRequest;
import com.model.user.User;
import com.model.user.UserDTO;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Mappings;
import org.mapstruct.factory.Mappers;

@Mapper
public interface UserMapper {

    UserMapper INSTANCE = Mappers.getMapper(UserMapper.class);
    @Mappings({
            @Mapping(target = "username", source = "username"),
            @Mapping(target = "password", source = "password"),
            @Mapping(target = "role", source = "role"),
            @Mapping(target = "clientId",source = "id")
    })
    UserDTO userToUserDTO(User user);

    @Mappings({
            @Mapping(target = "role", constant = "USER")
    })
    User toUser(RegisterRequest registerRequest);
}


