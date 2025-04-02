package com.repository;

import com.model.PedidoEntry;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PedidoEntryRepository extends MongoRepository<PedidoEntry, String> {
    List<PedidoEntry> findAllByUserId(String userId);

    List<PedidoEntry> findAllByGameId(String gameId);

    List<PedidoEntry> findAllByOrderId(String orderId);

    void deleteAllByOrderId(String orderId);

    boolean existsByOrderId(String orderId);
}
