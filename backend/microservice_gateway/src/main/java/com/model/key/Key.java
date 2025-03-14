package com.model.key;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "secret_keys")
@Data
public class Key {

    @Id
    @GeneratedValue
    private long id;
    private String key;
    private String value;
}
