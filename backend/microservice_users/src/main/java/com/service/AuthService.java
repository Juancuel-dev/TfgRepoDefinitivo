package com.service;

import com.model.token.TokenRequest;
import com.util.Role;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class AuthService {

    private final Authentication authentication;

    public AuthService() {
        authentication= SecurityContextHolder.getContext().getAuthentication();
    }

    public boolean isSameUser(String username){
        if (authentication.getPrincipal() instanceof UserDetails) {
            return ((UserDetails) authentication.getPrincipal()).getUsername().equals(username);
        } else {
            return false;
        }
    }

}
