package com.util.exception;

public class UserIdNotFoundException extends Exception {
    public UserIdNotFoundException(String mensaje) {
        super(mensaje);
    }
}
