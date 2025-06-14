package com.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LoginRequest {

    @JsonProperty("username")
    private String username;
    @JsonProperty("password")
    private String password;
}
