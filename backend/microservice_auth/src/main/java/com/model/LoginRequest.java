package com.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

@Setter
@Data
@AllArgsConstructor
@NoArgsConstructor
public class LoginRequest implements UserDetails {

    private String username;
    private String password;
    private List<String> roles; // Lista de roles como cadenas (puedes modificar esto según tu necesidad)

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // Convertir los roles a SimpleGrantedAuthority
        return roles.stream()
                .map(SimpleGrantedAuthority::new) // Convierte cada rol en un SimpleGrantedAuthority
                .collect(Collectors.toList());
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    protected Object clone() throws CloneNotSupportedException {
        return super.clone();
    }

    @Override
    public boolean isAccountNonExpired() {
        return true; // Modificado para siempre retornar true, puedes ajustarlo según tu lógica
    }

    @Override
    public boolean isAccountNonLocked() {
        return true; // Lo mismo, ajusta según lo que necesites
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true; // Lo mismo
    }

    @Override
    public boolean isEnabled() {
        return true; // Lo mismo
    }
}
