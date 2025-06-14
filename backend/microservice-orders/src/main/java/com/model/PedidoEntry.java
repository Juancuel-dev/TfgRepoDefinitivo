package com.model;


import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDate;
import java.util.List;

@Document("orders")
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
    private String clientId;

    @Field
    private Float precio;

    @Field
    private LocalDate fecha;

    @Field
    private List<CartItem> games;
}
