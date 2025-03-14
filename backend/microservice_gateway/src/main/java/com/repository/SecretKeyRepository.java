package com.repository;

import lombok.AllArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
@AllArgsConstructor
public class SecretKeyRepository {

    private JdbcTemplate jdbcTemplate;

    public String getSecretKey() {
        String query = "SELECT key_value FROM secret_keys WHERE key_name = 'jwt_secret_key";
        return jdbcTemplate.queryForObject(query, String.class);
    }
}

