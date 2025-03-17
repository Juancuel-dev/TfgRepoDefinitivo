package com.model.key;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document("keys")
@Data
public class Key {

    @Id
    private String id;
    private String nombre;
    private String valor;
}
