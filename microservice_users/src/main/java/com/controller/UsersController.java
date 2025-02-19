package com.controller;

import com.model.User;
import com.model.UserDTO;
import com.service.UserServiceCmdImpl;
import com.util.UserMapper;
import org.springframework.data.crossstore.ChangeSetPersister.NotFoundException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/users")
public class UsersController {

    private final UserServiceCmdImpl UsersService;
    private final UserServiceCmdImpl userServiceCmdImpl;

    // Constructor de inyección de dependencias
    public UsersController(UserServiceCmdImpl UsersService, UserServiceCmdImpl userServiceCmdImpl)
    {
        this.UsersService = UsersService;
        this.userServiceCmdImpl = userServiceCmdImpl;
    }

    // Obtener todos los usuarios
    @GetMapping
    public ResponseEntity<List<User>> findAll()
    {
        return ResponseEntity.ok(UsersService.findAll());
    }

    // Obtener un usuario por id
    @GetMapping("/{id}")
    public ResponseEntity<User> findById(@PathVariable Long id)
    {
        try {
            return ResponseEntity.ok(UsersService.findById(id));
        } catch (NotFoundException nfe) {
            return ResponseEntity.notFound().build();
        }
    }

    // Obtener un usuario por id
    @GetMapping("/search")
    public ResponseEntity<User> findByUsername(@RequestParam String username)
    {
        try {
            return ResponseEntity.ok(UsersService.findByUsername(username));
        } catch (NotFoundException nfe) {
            return ResponseEntity.notFound().build();
        }
    }

    // Crear un nuevo usuario
    @PostMapping
    public ResponseEntity<User> save(@RequestBody User User)
    {
        User savedUser = UsersService.save(User);
        // Retornar 201 Created con la URL del nuevo recurso
        if (savedUser.getId() == null) {
            throw new RuntimeException("No se pudo obtener la URL del recurso creado");
        }
        URI uri = UriComponentsBuilder.fromPath("/users/{id}")
                .buildAndExpand(savedUser.getId())
                .toUri();
        return ResponseEntity.created(uri).body(savedUser); // Idealmente, deberías incluir la URL del recurso creado.
    }

    // Crear un nuevo usuario
    @PostMapping("/all")
    public ResponseEntity<List<User>> saveAll(@RequestBody List<User> Users)
    {
        List<User> savedUsers = UsersService.saveAll(Users);
        // Retornar 201 Created con la URL del nuevo recurso
        if (savedUsers.get(1).getId() == null) {
            throw new RuntimeException("No se pudo obtener la URL del recurso creado");
        }
        URI uri = UriComponentsBuilder.fromPath("/Users/{id}")
                .buildAndExpand(savedUsers.hashCode())
                .toUri();
        return ResponseEntity.created(uri).body(savedUsers); // Idealmente, deberías incluir la URL del recurso creado.
    }

    // Actualizar un usuario existente
    @PutMapping("/{id}")
    public ResponseEntity<User> update(@PathVariable Long id, @RequestBody User user)
    {
        user.setId(id);  // No queremos dar un nuevo id al usuario actualizado
        try {
            UsersService.update(user);  // Llamamos al servicio para actualizar el usuario
            return ResponseEntity.noContent().build();
        } catch (NotFoundException nfe) {
            return ResponseEntity.notFound().build();
        }  // Retornamos 204 No Content si el usuario se eliminó correctamente
    }


    // Eliminar un usuario por id
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id)
    {
        try {
            UsersService.deleteById(id);  // Llamamos al servicio para eliminar el usuario
            return ResponseEntity.noContent().build();
        } catch (NotFoundException nfe) {
            return ResponseEntity.notFound().build(); // Retornamos 204 No Content si el usuario se eliminó correctamente
        }
    }

    @GetMapping("/auth")
    public ResponseEntity<UserDTO> getUserDTOByUsername(@RequestParam String username){
        try{
            return ResponseEntity.ok(UserMapper.INSTANCE.userToUserDTO(userServiceCmdImpl.findByUsername(username)));
        }catch(NotFoundException nfe){
            return ResponseEntity.notFound().build();
        }
    }
}

