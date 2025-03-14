package com.model.key;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "secret_keys")
@Data
public class Key {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String nombre;
    private String valor;
}
