package com.viewnext.controller;

import com.viewnext.model.MailRequest;
import com.viewnext.model.MailResponse;
import com.viewnext.service.EmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/mail")
@RequiredArgsConstructor
public class EmailController {

    private final EmailService emailService;

    @PostMapping
    public ResponseEntity<MailResponse> email(@RequestBody MailRequest mailRequest) {
        try{
            return ResponseEntity.ok(emailService.send(mailRequest));
        }catch (Exception e){
            return ResponseEntity.badRequest().build();
        }
    }
}