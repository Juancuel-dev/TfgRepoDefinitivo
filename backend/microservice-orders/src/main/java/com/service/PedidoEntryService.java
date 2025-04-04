package com.service;

import com.model.PedidoEntry;
import com.repository.PedidoEntryRepository;
import com.util.exception.*;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.util.List;


@Service
@RequiredArgsConstructor
public class PedidoEntryService {

    private final PedidoEntryRepository repository;

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

    public List<PedidoEntry> findAllByGameId(Jwt jwt, String gameId) throws GameIdNotFoundException, UnauthorizedException {
        if (jwt.getClaim("role").equals("ADMIN")) {
            return repository.findAllByGameId(gameId).orElseThrow(() -> new GameIdNotFoundException("Pedido no encontrado."));
        } else {
            throw new UnauthorizedException("No estas autorizado para realizar esta accion");
        }
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


    public PedidoEntry save(Jwt jwt, PedidoEntry pedidoEntry) throws DataIntegrityViolationException {
        return repository.save(pedidoEntry);
    }

    public List<PedidoEntry> saveAll(Jwt jwt, List<PedidoEntry> pedidoEntry) {
        return repository.saveAll(pedidoEntry);
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
}