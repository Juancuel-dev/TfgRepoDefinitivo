package com.controller;

import com.model.auth.AuthenticationResponse;
import com.model.login.LoginRequest;
import com.model.login.LoginResponse;
import com.model.register.RegisterRequest;
import com.model.user.UserDTO;
import com.service.AuthService;
import com.service.JwtService;
import com.util.exception.ClienteNotFoundException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
    private final JwtService jwtService;

    private final AuthService authenticationService;

    @PostMapping("/register")
    public ResponseEntity<UserDTO> register(@Valid @RequestBody RegisterRequest registerUserDto) {
        UserDTO registeredUser = authenticationService.signup(registerUserDto);

        return ResponseEntity.created(URI.create("/")).body(registeredUser);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> authenticate(@Valid @RequestBody LoginRequest loginUserDto) {
        UserDTO authenticatedUser = authenticationService.authenticate(loginUserDto);

        String jwtToken = jwtService.generateToken(authenticatedUser);

        return ResponseEntity.ok(new LoginResponse(jwtToken));
    }

    @GetMapping("/.well-known/jwks.json")
    public ResponseEntity<String> getJwks() {
        // Carga la clave pública desde un archivo o una base de datos
        String publicKey = """
                -----BEGIN PUBLIC KEY-----
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy8Dbv8prpJ/0kKhlGeJY
                ozo2t60EG8L0561g13R29LvMR5hyvGZlGJpmn65+A4xHXInJYiPuKzrKfDNSH6h
                -----END PUBLIC KEY-----""";
        return ResponseEntity.ok().body(publicKey);
    }

    @PostMapping("/validate-token")
    public ResponseEntity<Boolean> validateToken(@RequestHeader("Authorization") String token) {
        return ResponseEntity.ok(jwtService.isTokenValid(token));
    }

    @PostMapping("/has-role/{role}")
    public ResponseEntity<Boolean> hasRole(@RequestHeader("Authorization") String token, @PathVariable String role) {

        if (jwtService.isTokenValid(token)){
                return ResponseEntity.ok(jwtService.hasRole(token,role));
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();

    }

    @GetMapping("/token-info")
    public ResponseEntity<AuthenticationResponse> getTokenInfo(@RequestHeader("Authorization") String token) throws ClienteNotFoundException {

        if(token.contains("Bearer")){
            token = token.substring(7);
        }
            UserDTO client = authenticationService.loadByClientId(jwtService.extractClientId(token));
            List<String> authorities = jwtService.extractAuthorities(token);
            return ResponseEntity.ok(new AuthenticationResponse(client.getUsername(), authorities, client.getClientId(), client.getEmail()));
        }

    @GetMapping("/{clientId}/email")
    public ResponseEntity<String> getEmail(@RequestHeader("Authorization") String token, @PathVariable String clientId) {

        if (jwtService.isTokenValid(token) && (jwtService.hasRole(token, "ADMIN"))|| jwtService.extractClientId(token).equals(clientId)) {

            try {
                return ResponseEntity.ok(authenticationService.getEmail(clientId));

            } catch (ClienteNotFoundException cinfe) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
            }
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }

    @GetMapping("/{clientId}/info")
    public ResponseEntity<UserDTO> getUserInfo(@RequestHeader("Authorization") String token, @PathVariable String clientId) {
        // Verifica el token de acceso
        if (jwtService.isTokenValid(token) && jwtService.hasRole(token, "ADMIN")) {
            try {
                return ResponseEntity.ok(authenticationService.loadByClientId(clientId));
            }catch (ClienteNotFoundException cinfe) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
            }
        }return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }

    @PostMapping("/change-password/{password}")
    public ResponseEntity<?> cambiarContrasenia(@AuthenticationPrincipal Jwt jwt, @PathVariable String password){
        try {
            return ResponseEntity.ok(authenticationService.cambiarContrasenia(jwt,password));
        } catch (ClienteNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminarUsuario(@AuthenticationPrincipal Jwt jwt, @PathVariable String id){
        try {
            authenticationService.delete(jwt,id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

}
