package com.service;

import com.model.User;
import com.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.data.crossstore.ChangeSetPersister.NotFoundException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

@Service
@AllArgsConstructor
public class UserServiceCmdImpl implements UserServiceCmd {

    private final UserRepository userRepository;
    private PasswordEncoder passwordEncoder;

    // Obtener todos los juegos
    public List<User> findAll() {
        return userRepository.findAll();
    }

    // Buscar un juego por su ID
    public User findById(Long id) throws NotFoundException{
        return userRepository.findById(id)
                .orElseThrow(NotFoundException::new);
    }

    @Override
    public User findByUsername(String username) throws NotFoundException {
        return userRepository.findByUsername(username)
                .orElseThrow(NotFoundException::new);
    }

    // Guardar un juego (crear o actualizar)
    public User save(User user) {
        String encryptedPassword = passwordEncoder.encode(user.getPassword());
        user.setPassword(encryptedPassword);
        return userRepository.save(user);
    }

    // Guardar un juego (crear o actualizar)
    public List<User> saveAll(List<User> users) {
        // Cifrar las contraseñas de todos los usuarios
        users.forEach(user -> {
            String encryptedPassword = passwordEncoder.encode(user.getPassword());
            user.setPassword(encryptedPassword);
        });

        // Lógica para guardar los usuarios en la base de datos
        return userRepository.saveAll(users);
    }

    // Actualizar un juego
    public User update(User user) throws NotFoundException{
        // Buscar el juego por ID
        return userRepository.findById(user.getId())
                .map(buscado -> {
                    // Si el juego existe, actualizamos sus campos
                    buscado.setName(user.getName());
                    buscado.setEmail(user.getEmail());
                    buscado.setPassword(user.getPassword());
                    buscado.setAge(user.getAge());
                    buscado.setSurname1(user.getSurname1());
                    buscado.setSurname2(user.getSurname2());
                    buscado.setRoles(user.getRoles());
                    buscado.setUsername(user.getUsername());

                    return userRepository.save(buscado);
                })
                .orElseThrow(NotFoundException::new);
    }

    // Comprobar si un juego existe por su ID
    public boolean existsById(Long id) {
        return userRepository.existsById(id);
    }

    // Eliminar un juego por su ID
    public void deleteById(Long id) throws NotFoundException{
        if (!userRepository.existsById(id)) {
            throw new NotFoundException();
        }
        userRepository.deleteById(id);
    }

    @Override
    public boolean isAdmin() {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            return authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ADMIN"));

    }


}