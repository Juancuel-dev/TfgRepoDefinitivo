package com.model;

import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserDTO implements UserDetails {

    private String username;
    private String password;
    private List<String> roles; // Cambia esto a una lista de roles

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // Convierte los roles en una lista de GrantedAuthority
        return roles.stream()
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());
    }

    @Override
    public boolean isAccountNonExpired() {
        return true; // Puedes personalizar esto según tu lógica
    }

    @Override
    public boolean isAccountNonLocked() {
        return true; // Puedes personalizar esto según tu lógica
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true; // Puedes personalizar esto según tu lógica
    }

    @Override
    public boolean isEnabled() {
        return true; // Puedes personalizar esto según tu lógica
    }
}