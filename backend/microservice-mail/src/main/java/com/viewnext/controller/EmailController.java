package com.viewnext.controller;

import com.viewnext.model.MailRequest;
import com.viewnext.model.PurchaseMailRequest;
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
    public ResponseEntity<String> email(@RequestBody MailRequest mailRequest) {
        try{
            return ResponseEntity.ok(emailService.send(mailRequest));
        }catch (Exception e){
            return ResponseEntity.badRequest().build();
        }
    }
    @PostMapping("/purchase")
    public ResponseEntity<String> purchaseMail(@RequestBody PurchaseMailRequest request) {
        try{
            return ResponseEntity.ok(emailService.send(new MailRequest(request.getReceiver(), "Purchase from product " + request.getOrderId(),"inscription")));
        }catch (Exception e){
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}