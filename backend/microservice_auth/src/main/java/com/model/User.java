package com.model;

import lombok.Data;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.List;

@Data
public class User {
    private Long id;
    private String username;
    private String email;
    private List<SimpleGrantedAuthority> roles;
}