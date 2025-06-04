package com.model;

import lombok.*;
@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class UserDTO {

    private String username;

    private String email;

    private String nombre;

    private Integer imagen;

    private Byte edad;

    private String pais;

}