package com.repository;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import com.model.Game;

import java.util.List;
import java.util.Optional;

@Repository
public interface GamesRepository extends MongoRepository<Game,String> {

    List<Game> findAllByConsola(String consola);

    List<Game> findByNameRegex(String name);

    Optional<Object> findByName(String name);
}
