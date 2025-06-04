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

}