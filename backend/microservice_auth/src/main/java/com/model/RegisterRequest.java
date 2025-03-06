package com.model;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RegisterRequest {
    // Getters y Setters
    private String username;
    private String password;
    private String email;

}