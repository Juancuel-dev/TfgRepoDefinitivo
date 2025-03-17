package com.repository.key;

import com.model.key.Key;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface KeyRepository extends MongoRepository<Key, String> {
    Optional<Key> findByNombre(String nombre);
}
