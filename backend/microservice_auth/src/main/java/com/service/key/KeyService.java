package com.service.key;

import com.model.key.Key;
import com.repository.key.KeyRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.Base64;

@Service
@RequiredArgsConstructor
public class KeyService {

    private final KeyRepository keyRepository;

    public byte[] getSecurityKey(){

        return Base64
                        .getDecoder()
                        .decode(keyRepository
                                .findByNombre("jwtSecretSign")
                                .orElseThrow(EntityNotFoundException::new)
                                .getValor());
    }

    public Key saveSecurityKey(Key key){
        return keyRepository.save(key);
    }
}
