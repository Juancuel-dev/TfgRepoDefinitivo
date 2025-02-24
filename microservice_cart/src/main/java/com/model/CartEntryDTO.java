package com.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CartEntryDTO {

    private Long productId;

    private Long customerId;

    private Integer quantity;

}
