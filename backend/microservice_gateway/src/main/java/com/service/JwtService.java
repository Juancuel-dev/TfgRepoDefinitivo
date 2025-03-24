package com.service;

import com.model.AuthenticationResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;


@Service
@RequiredArgsConstructor
public class JwtService {

    private final RestTemplate restTemplate;
    private final String baseUrl = "http://localhost:8084/auth";

    public Mono<Boolean> isTokenValid(String token) {
        return Mono.fromCallable(() -> callAuthMicroServiceBoolean(token))
                .subscribeOn(Schedulers.boundedElastic());
    }

    public Mono<Authentication> getAuthentication(String token) {
        return Mono.fromCallable(() -> {
                    AuthenticationResponse auth = callAuthMicroServiceAuth(token);
                    if (auth != null) {
                        return (Authentication) new UsernamePasswordAuthenticationToken(
                                auth.getUsername(),
                                null,
                                auth.getAuthorities().stream()
                                        .map(SimpleGrantedAuthority::new)
                                        .toList());
                    }
                    return null;
                })
                .subscribeOn(Schedulers.boundedElastic());
    }

    public Mono<String> getUsernameFromToken(String token) {
        return Mono.fromCallable(() -> callAuthMicroServiceAuth(token))
                .map(AuthenticationResponse::getUsername)
                .subscribeOn(Schedulers.boundedElastic());
    }

    public Mono<String> getIdFromToken(String token) {
        return Mono.fromCallable(() -> callAuthMicroServiceAuth(token))
                .map(AuthenticationResponse::getClientId)
                .subscribeOn(Schedulers.boundedElastic());
    }

    public Mono<SimpleGrantedAuthority> getRoleFromToken(String token) {
        return Mono.fromCallable(() -> callAuthMicroServiceAuth(token))
                .flatMap(auth -> Mono.justOrEmpty(auth.getAuthorities().stream().findFirst()))
                .map(SimpleGrantedAuthority::new)
                .switchIfEmpty(Mono.error(new RuntimeException("No authorities found in token")))
                .subscribeOn(Schedulers.boundedElastic());
    }

    private AuthenticationResponse callAuthMicroServiceAuth(String token) {
        HttpHeaders headers = new HttpHeaders();
        String cleanToken = token.replace("Bearer ", "");
        headers.set(HttpHeaders.AUTHORIZATION, cleanToken);
        HttpEntity<String> entity = new HttpEntity<>("", headers);
        return restTemplate.exchange(
                baseUrl + "/token-info",
                HttpMethod.GET,
                entity,
                AuthenticationResponse.class
        ).getBody();
    }

    private Boolean callAuthMicroServiceBoolean(String token) {
        HttpHeaders headers = new HttpHeaders();
        String cleanToken = token.replace("Bearer ", "");
        headers.set(HttpHeaders.AUTHORIZATION, cleanToken);
        HttpEntity<String> entity = new HttpEntity<>("", headers);
        return restTemplate.exchange(
                baseUrl + "/validate-token",
                HttpMethod.POST,
                entity,
                Boolean.class
        ).getBody();
    }
}