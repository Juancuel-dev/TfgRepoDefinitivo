package com.util.exception;

public class OrderIdNotFoundException extends Exception {
    public OrderIdNotFoundException(String mensaje) {
        super(mensaje);
    }
}
