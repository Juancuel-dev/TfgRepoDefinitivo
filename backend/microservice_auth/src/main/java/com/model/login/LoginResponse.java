package com.model.login;

import lombok.*;

import java.io.Serializable;

@Data
@AllArgsConstructor
@Getter
@Setter
@NoArgsConstructor
public class LoginResponse implements Serializable {

    private String token;
    private long expiresIn;
}
