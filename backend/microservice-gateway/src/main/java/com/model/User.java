package com.model;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class User {

    private String id;

    private String username;

    private String password;

    private String email;

    private String nombre;

    private Integer imagen;

    private Byte edad;

    private String pais;

}