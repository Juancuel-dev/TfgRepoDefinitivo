package com;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

@SpringBootApplication
public class UsersApp {

    public static void main(String[] args) {
        SpringApplication.run(UsersApp.class, args);
    }
}