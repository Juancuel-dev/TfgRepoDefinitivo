package com.auth;

import com.model.UserDTO;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final RestTemplate restTemplate;

    public CustomUserDetailsService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // Llama al microservicio de usuarios para obtener el UserDTO
        String url = "http://localhost:8080/users/auth?username=" + username; // Ajusta la URL según tu microservicio
        UserDTO userDTO = restTemplate.getForObject(url, UserDTO.class);

        if (userDTO == null) {
            throw new UsernameNotFoundException("Usuario no encontrado: " + username);
        }

        // Devuelve el UserDTO como UserDetails
        return userDTO;
    }
}
