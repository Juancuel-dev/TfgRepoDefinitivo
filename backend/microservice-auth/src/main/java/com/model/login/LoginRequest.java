package com.model.login;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.io.Serializable;

@Data
@AllArgsConstructor
public class LoginRequest implements Serializable {

    @JsonProperty("username")
    private String username;
    @JsonProperty("password")
    private String password;
}
