package com.model;

import lombok.*;

@Data
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MasVendido {
    private Integer cantidad;
    private GameDTO game;
}
