package com.service.user;

import com.model.user.User;
import com.model.user.UserDTO;
import com.repository.user.UserRepository;
import com.util.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return UserMapper.INSTANCE.userToUserDTO(userRepository.findByUsername(username).orElseThrow(()->new UsernameNotFoundException("Usuario no encontrado con username " + username)));
    }

    public UserDetails loadUserById(String id) throws UsernameNotFoundException {
        return UserMapper.INSTANCE.userToUserDTO(userRepository.findById(id).orElseThrow(()->new UsernameNotFoundException("Usuario no encontrado con id " + id)));
    }
}