package com.repository.key;

import com.model.key.Key;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface KeyRepository extends JpaRepository<Key, Integer> {
    Optional<Key> findByNombre(String nombre);
}
