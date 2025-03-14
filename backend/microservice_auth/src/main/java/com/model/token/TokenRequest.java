package com.model.token;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class TokenRequest {

    private String username;
    private String password;
    private String token;
}
