package com.service.user;

import com.model.User;
import com.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.Data;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;


@Service
@Data
public class UserService {

    private final UserRepository userRepository;

    public User findByUsername(String username) throws EntityNotFoundException {
        return userRepository.findByUsername(username).orElseThrow(() -> new EntityNotFoundException("User " + username + " not found"));
    }

}
