package tfg;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.reactive.ReactiveUserDetailsServiceAutoConfiguration;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;

@SpringBootApplication(
        exclude = ReactiveUserDetailsServiceAutoConfiguration.class)
@EnableWebFluxSecurity
public class App {

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

}
