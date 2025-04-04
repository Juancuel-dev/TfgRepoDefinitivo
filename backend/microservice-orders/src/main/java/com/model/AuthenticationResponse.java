package com.model;

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

}
