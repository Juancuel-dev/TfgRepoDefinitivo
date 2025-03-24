package com.model.user;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@Document("users_auth")
@Data
@NoArgsConstructor
public class User{

    @Id
    private String id;

    @Indexed(unique = true)
    private String username;
    private String password;
    private String email;
    private String role;

    public User(String id,String username, String password, String role, String email) {
        this.id=id;
        this.username = username;
        this.password = password;
        this.role = role;
        this.email = email;
    }
}