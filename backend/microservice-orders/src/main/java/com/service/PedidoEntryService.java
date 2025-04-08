package com.service;

import com.model.GameDTO;
import com.model.MasVendido;
import com.model.PedidoEntry;
import com.repository.PedidoEntryRepository;
import com.util.exception.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;


@Service
@RequiredArgsConstructor
public class PedidoEntryService {

    private final PedidoEntryRepository repository;
    private final RestTemplate restTemplate;

    @Value("${ruta.gateway}")
    private String rutaGateway;


    public List<PedidoEntry> findAll(Jwt jwt) throws UnauthorizedException {
        if (jwt.getClaim("role").equals("ADMIN")) {
            return repository.findAll();
        } else {
            throw new UnauthorizedException("No estas autorizado para realizar esta accion");
        }
    }

    public PedidoEntry findById(Jwt jwt, String clientId, String id) throws PedidoEntryNotFoundException, UnauthorizedException {
        if (jwt.getClaim("role").equals("ADMIN") || jwt.getClaim("clientId").equals(clientId)) {
            return repository.findById(id).orElseThrow(() -> new PedidoEntryNotFoundException("Pedido no encontrado."));
        } else {
            throw new UnauthorizedException("No estas autorizado para realizar esta accion");
        }
    }

    public List<PedidoEntry> findAllByUserId(Jwt jwt, String clientId) throws UnauthorizedException, UserIdNotFoundException {
        if (jwt.getClaim("role").equals("ADMIN") || jwt.getClaim("clientId").equals(clientId)) {
            return repository.findAllByClientId(clientId).orElseThrow(() -> new UserIdNotFoundException("Pedido no encontrado."));
        } else {
            throw new UnauthorizedException("No estas autorizado para realizar esta accion");
        }
    }

    public List<GameDTO> getJuegosFromOrder(Jwt jwt,String orderId) throws PedidoEntryNotFoundException {
        return repository.findById(orderId).orElseThrow(()-> new PedidoEntryNotFoundException("Pedido no encontrado")).getJuegos();
    }

    public List<PedidoEntry> findAllByOrderId(Jwt jwt, String orderId) throws OrderIdNotFoundException, UnauthorizedException {
        List<PedidoEntry> pedidoEntry = repository.findAllByOrderId(orderId).orElseThrow(() -> new OrderIdNotFoundException("Pedido no encontrado."));
        if (isAuthorized(jwt, pedidoEntry)) {
            return pedidoEntry;
        } else {
            throw new UnauthorizedException("No estas autorizado para realizar esta accion");
        }
    }

    private boolean isAuthorized(Jwt jwt, List<PedidoEntry> pedidoEntry) {
        return pedidoEntry.stream().anyMatch(entry -> entry.getClientId().equals(jwt.getClaim("clientId"))) || jwt.getClaim("role").equals("ADMIN");
    }

    public Float getTotalPrice(Jwt jwt, String orderId) throws  UnauthorizedException, OrderIdNotFoundException {

        List<PedidoEntry> entries = this.findAllByOrderId(jwt,orderId);
        final Float[] totalPrice = {0f};
        entries.forEach(pedido-> totalPrice[0] +=pedido.getPrecio());
            return totalPrice[0];
        }


    public PedidoEntry save(Jwt jwt, PedidoEntry pedidoEntry) throws DataIntegrityViolationException, UnauthorizedException {
        if(jwt.getClaim("clientId").equals(pedidoEntry.getClientId())) {
            restTemplate.postForObject(rutaGateway, pedidoEntry, ResponseEntity.class);
            return repository.save(pedidoEntry);
        }else{
            throw new UnauthorizedException("No estas autorizado a realizar esta accion");
        }
    }

    public List<PedidoEntry> saveAll(Jwt jwt, List<PedidoEntry> pedidoEntry) throws UnauthorizedException {
        if(jwt.getClaim("role").equals("ADMIN")) {
            return repository.saveAll(pedidoEntry);
        }else{
            throw new UnauthorizedException("No estas autorizado para realizar esta accion");
        }
    }

    public void deleteAllByOrderId(Jwt jwt, String orderId) throws UnauthorizedException {
        if (jwt.getClaim("role").equals("ADMIN")) {
            repository.deleteAllByOrderId(orderId);
        } else {
            throw new UnauthorizedException("No estas autorizado para realizar esta accion");
        }
    }

    public boolean existsOrderId(Jwt jwt, String orderId) throws UnauthorizedException {
        if (jwt.getClaim("role").equals("ADMIN")) {

            return repository.existsByOrderId(orderId);
        } else {
            throw new UnauthorizedException("No estas autorizado para realizar esta accion");
        }
    }

    public List<MasVendido> mostPurchasedGames(Jwt jwt, int cuantos) throws UnauthorizedException {
        if (jwt.getClaim("role").equals("ADMIN")) {
            List<PedidoEntry> entries = findAll(jwt);
            Map<GameDTO,Long> frecuencia = entries.stream()
                    .flatMap(entry -> entry.getJuegos().stream())
                    .collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));

            return frecuencia.entrySet().stream()
                    .sorted((e1, e2) -> e2.getValue().compareTo(e1.getValue()))
                    .limit(cuantos)
                    .map(entry -> {
                        MasVendido masVendido = new MasVendido();
                        masVendido.setCantidad(entry.getValue().intValue());
                        masVendido.setGame(entry.getKey());
                        return masVendido;
                    })
                    .collect(Collectors.toList());


        }else{
            throw new UnauthorizedException("No estas autorizado para realizar esta accion");
        }
    }
}