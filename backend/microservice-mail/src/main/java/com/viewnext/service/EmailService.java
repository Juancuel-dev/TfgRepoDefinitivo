package com.viewnext.service;

import com.viewnext.model.MailRequest;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ClassPathResource;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.io.*;
import java.nio.charset.StandardCharsets;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSenderImpl mailSender;

    public String send(MailRequest request) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);
            helper.setTo(request.getTo());
            helper.setSubject(request.getSubject());
            helper.setText(readFileFromClasspath(request.getFileName() + ".html"), true);
            mailSender.send(message);
            return "Mensaje enviado correctamente a " + request.getTo();
        } catch (MessagingException e) {
            return "Error al enviar el mensaje: " + e.getMessage();
        }
    }

    private String readFileFromClasspath(String fileName) {
        ClassPathResource resource = new ClassPathResource(fileName);
        if (!resource.exists()) {
            throw new RuntimeException("El archivo " + fileName + " no existe en el classpath");
        }
        try (InputStream inputStream = resource.getInputStream()) {
            return new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new RuntimeException("Error al leer el archivo " + fileName, e);
        }
    }

}
