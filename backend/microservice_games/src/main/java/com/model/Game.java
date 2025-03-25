package com.model;

import lombok.*;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

@Data
@Document(collection = "games")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class Game {

    @Id
    private String id;  // En MongoDB, el ID es típicamente de tipo String, no Long.

    @Field("name")
    private String name;

    @Field("description")
    private String description;

    @Field("creator")
    private String creator;

    @Field("price")
    private Float precio;

    @Field("stock")
    private Integer stock;

    @Field("metacritic")
    private Integer metacritic;

    @Field("consola")
    private String consola;

    @Field("imagen")
    private String imagen;

}