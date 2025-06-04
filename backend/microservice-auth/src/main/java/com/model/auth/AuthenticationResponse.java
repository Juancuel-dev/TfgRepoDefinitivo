package com.model.auth;

import lombok.*;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class AuthenticationResponse {
    private String username;
    private List<String> authorities;
    private String clientId;
    private String email;

}
