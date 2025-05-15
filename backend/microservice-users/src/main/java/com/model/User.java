package com.model;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Document("users")
public class User {

    @Id
    private String id;

    private String username;

    private String email;

    private String nombre;

    private Integer imagen;

    private Byte edad;

    private String pais;
}