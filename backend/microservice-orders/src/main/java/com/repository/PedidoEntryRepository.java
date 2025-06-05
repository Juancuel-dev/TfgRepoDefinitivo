package com.repository;

import com.model.PedidoEntry;
import com.util.exception.UserIdNotFoundException;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface PedidoEntryRepository extends MongoRepository<PedidoEntry, String> {
    Optional<List<PedidoEntry>> findAllByClientId(String clientId) throws UserIdNotFoundException;

    Optional<List<PedidoEntry>> findAllByOrderId(String orderId);

    void deleteAllByOrderId(String orderId);

    boolean existsByOrderId(String orderId);

    List<PedidoEntry> findAllByFecha(LocalDate fecha);
}
