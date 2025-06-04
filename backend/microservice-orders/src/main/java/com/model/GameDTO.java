package com.model;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class GameDTO {

    private String name;
    private Float precio;
    private Integer metacritic;
    private String consola;

    // Constructor de copia
    public GameDTO(GameDTO game) {

        this.name = game.getName();
        this.precio = game.precio;
        this.metacritic = game.metacritic;
        this.consola = game.consola;
    }
}