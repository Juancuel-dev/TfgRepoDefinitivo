package gateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.web.server.SecurityWebFilterChain;

import static org.springframework.security.config.Customizer.withDefaults;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityWebFilterChain securityWebFilterChain(ServerHttpSecurity http) {
        http
                .authorizeExchange(exchange -> exchange
                        .pathMatchers("/actuator/**", "/", "/logout.html").permitAll()
                        .anyExchange().authenticated()
                )
                .oauth2Login(withDefaults())
                .logout(logoutSpec -> logoutSpec.logoutUrl("/logout.html"));

        return http.build();
    }

    @Bean
    public ServerHttpSecurity http() {
        return ServerHttpSecurity.http();
    }
}
