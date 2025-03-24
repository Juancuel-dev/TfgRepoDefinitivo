package com.viewnext.model;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class Auth {

    private String username;
    private String password;

    private String token;
}
