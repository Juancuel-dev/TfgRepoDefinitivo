package com.repository;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import com.model.Game;

import java.util.List;

@Repository
public interface GamesRepository extends MongoRepository<Game,String> {

    List<Game> findAllByConsola(String consola);
}
