package com.model;

import lombok.Data;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

@Data
@Document(collection = "games")  // Indica que la clase Game corresponde a la colección "games" en MongoDB
public class Game {

    private static int cuantosId = 0;
    @Id
    private String id;  // En MongoDB, el ID es típicamente de tipo String, no Long.

    @Field("name")
    private String name;

    @Field("description")
    private String description;

    @Field("creator")
    private String creator;

    @Field("price")
    private Integer precio;

    @Field("stock")
    private Integer stock;

    @Field("metacritic")
    private Integer metacritic;

    @Field("consola")
    private String consola;

    // Constructor parametrizado
    public Game(String name, String description, String creator, Integer precio, Integer stock, Integer metacritic, String consola) {

        cuantosId++;
        this.id = cuantosId + "";
        this.name = name;
        this.description = description;
        this.creator = creator;
        this.precio = precio;
        this.stock = stock;
        this.metacritic = metacritic;
        this.consola = consola;
    }

    // Constructor por defecto
    public Game() {
        cuantosId++;
        this.id = cuantosId + "";
        this.name = "";
        this.description = "";
        this.creator = "";
        this.precio = -1;
        this.stock = -1;
        this.metacritic = -1;
        this.consola = "";
    }

    // Constructor de copia
    public Game(Game game) {

        cuantosId++;
        this.id = cuantosId + "";
        this.name = game.getName();
        this.description = game.description;
        this.creator = game.creator;
        this.precio = game.precio;
        this.stock = game.stock;
        this.metacritic = game.metacritic;
        this.consola = game.consola;
    }
}