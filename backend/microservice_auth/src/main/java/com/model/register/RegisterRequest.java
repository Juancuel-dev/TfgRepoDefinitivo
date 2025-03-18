package com.model.register;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.io.Serializable;

@Setter
@Getter
@Data
@AllArgsConstructor
@NoArgsConstructor
public class RegisterRequest implements Serializable {

    // Getters y Setters

    private String id;
    @JsonProperty("username")
    private String username;
    @JsonProperty("password")
    private String password;
    @JsonProperty("email")
    private String email;

}