package com.model;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class PurchaseMailRequest {
    private String receiver;
    private String orderId;
}
