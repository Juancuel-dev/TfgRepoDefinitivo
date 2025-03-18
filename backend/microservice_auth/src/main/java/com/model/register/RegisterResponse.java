package com.model.register;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.io.Serializable;

@AllArgsConstructor
@Data
public class RegisterResponse implements Serializable {

    private String message;
}

