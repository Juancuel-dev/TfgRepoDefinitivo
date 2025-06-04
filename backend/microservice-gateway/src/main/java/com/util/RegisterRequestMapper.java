package com.util;

import com.model.register.RegisterAuthRequest;
import com.model.register.RegisterUsersRequest;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

@Mapper
public interface RegisterRequestMapper {

    RegisterRequestMapper INSTANCE = Mappers.getMapper(RegisterRequestMapper.class);
    RegisterAuthRequest toRegisterAuthRequest(RegisterUsersRequest request);
}