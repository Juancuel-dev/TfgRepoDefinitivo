package com.service;

import com.cohere.api.Cohere;
import com.cohere.api.resources.v2.requests.V2ChatRequest;
import com.cohere.api.types.*;
import org.springframework.security.oauth2.jwt.Jwt;

import java.util.List;

public class AIService {
    public static AssistantMessageResponse escribir(Jwt jwt, String texto) {
        Cohere cohere = Cohere.builder().token("4t4RczaG6rD846LEqq2Lm18ftFSxehFOECTfLoJQ").clientName("app").build();
        ChatResponse response;
        if(jwt!=null && texto!=null) {
            response =
                    cohere.v2()
                            .chat(
                                    V2ChatRequest.builder()
                                            .model("command-a-03-2025")
                                            .messages(
                                                    List.of(
                                                            ChatMessageV2.user(
                                                                    UserMessage.builder()
                                                                            .content(
                                                                                    UserMessageContent
                                                                                            .of("Hola, mi nombre es " + jwt.getClaim("username") + " ," + texto))
                                                                            .build())))
                                            .build());
        }else{
            response =
                    cohere.v2()
                            .chat(
                                    V2ChatRequest.builder()
                                            .model("command-a-03-2025")
                                            .messages(
                                                    List.of(
                                                            ChatMessageV2.user(
                                                                    UserMessage.builder()
                                                                            .content(
                                                                                    UserMessageContent
                                                                                            .of(texto))
                                                                            .build())))
                                            .build());
        }

        return response.getMessage();
    }
}

