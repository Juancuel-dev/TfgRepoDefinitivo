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
    private String id;

    @Field("name")
    private String name;

    @Field("precio")
    private Float precio;

    @Field("metacritic")
    private Integer metacritic;

    @Field("consola")
    private String consola;

    @Field("imagen")
    private String imagen;

    @Field("descripcion")
    private String descripcion;

}