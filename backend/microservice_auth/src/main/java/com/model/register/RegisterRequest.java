package com.model.register;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RegisterRequest {

    // Getters y Setters
    private String username;
    private String password;
    private String email;

    private String nombre;

    private Integer telefono;

    private String apellido1;

}