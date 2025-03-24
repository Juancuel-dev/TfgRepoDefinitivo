package com.viewnext.controller;

import com.viewnext.model.MailRequest;
import com.viewnext.service.EmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/mail")
@RequiredArgsConstructor
public class EmailController {

    private final EmailService emailService;

    @PostMapping
    public void email(@RequestBody MailRequest mailRequest) {
        try{
            emailService.send(mailRequest);
        }catch (Exception e){
            e.printStackTrace();
        }
    }




}
