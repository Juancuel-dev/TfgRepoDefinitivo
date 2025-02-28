package com.repository;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import com.model.Game;

@Repository
public interface GamesRepository extends MongoRepository<Game,String> {

}
