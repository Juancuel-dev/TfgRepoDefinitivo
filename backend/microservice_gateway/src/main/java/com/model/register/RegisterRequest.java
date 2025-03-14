package com.model.register;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RegisterRequest {
    @JsonProperty("username")
    private String username;
    @JsonProperty("password")
    private String password;
    @JsonProperty("email")
    private String email;
    @JsonProperty("nombre")
    private String nombre;
    @JsonProperty("telefono")
    private Integer telefono;
    @JsonProperty("apellido1")
    private String apellido1;
}
