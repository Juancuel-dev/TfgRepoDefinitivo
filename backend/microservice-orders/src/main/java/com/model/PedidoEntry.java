package com.model;


import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDate;

@Document("pedidos")
@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class PedidoEntry {

    @Id
    private String id;

    @Field
    private String orderId;

    @Field
    private String userId;

    @Field
    private String gameId;

    @Field
    private String precio;

    @Field
    private LocalDate fecha;
}
