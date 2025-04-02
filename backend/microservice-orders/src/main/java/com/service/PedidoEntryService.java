package com.service;

import com.model.PedidoEntry;
import com.repository.PedidoEntryRepository;
import com.util.exception.PedidoEntryNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PedidoEntryService {

    private PedidoEntryRepository repository;

    public List<PedidoEntry> findAll(){
        return repository.findAll();
    }
    public PedidoEntry findById(String id) throws PedidoEntryNotFoundException {
        return repository.findById(id).orElseThrow(()->new PedidoEntryNotFoundException("Pedido no encontrado"));
    }
    public List<PedidoEntry> findAllByUserId(String userId) {
        return repository.findAllByUserId(userId);
    }

    public List<PedidoEntry> findAllByGameId(String gameId){
        return repository.findAllByGameId(gameId);
    }

    public List<PedidoEntry> findAllByOrderId(String orderId){
        return repository.findAllByOrderId(orderId);
    }

    public PedidoEntry save(PedidoEntry pedidoEntry) {
        return repository.save(pedidoEntry);
    }

    public List<PedidoEntry> saveAll(List<PedidoEntry> pedidoEntry) {
        return repository.saveAll(pedidoEntry);
    }

    public void deleteAllByOrderId(String orderId) {
        repository.deleteAllByOrderId(orderId);
    }

    public boolean existsOrderId(String orderId) {
        return repository.existsByOrderId(orderId);
    }
}
