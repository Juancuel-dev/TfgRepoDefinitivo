package com.service;

import com.model.User;
import com.repository.UserRepository;
import org.springframework.data.crossstore.ChangeSetPersister.NotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserServiceCmdImpl implements UserServiceCmd {

    private final UserRepository userRepository;

    // Constructor de inyección de dependencias
    public UserServiceCmdImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

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
    public User save(User User) {
        return userRepository.save(User);
    }

    // Guardar un juego (crear o actualizar)
    public List<User> saveAll(List<User> Users) {
        return userRepository.saveAll(Users);
    }

    // Actualizar un juego
    public User update(User User) throws NotFoundException{
        // Buscar el juego por ID
        return userRepository.findById(User.getId())
                .map(buscado -> {
                    // Si el juego existe, actualizamos sus campos
                    buscado.setName(User.getName());
                    buscado.setEmail(User.getEmail());
                    buscado.setPassword(User.getPassword());
                    buscado.setAge(User.getAge());
                    buscado.setSurname1(User.getSurname1());
                    buscado.setSurname2(User.getSurname2());
                    buscado.setRoles(User.getRoles());
                    buscado.setUsername(User.getUsername());

                    return userRepository.save(buscado);
                })
                .orElseThrow(() -> new NotFoundException());
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
}