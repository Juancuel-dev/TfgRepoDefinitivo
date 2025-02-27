package com.repository;

import com.model.CartEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CartEntryRepository extends JpaRepository<CartEntry, Long> {
    List<CartEntry> findByCustomerId(Long costumerId);

    Optional<CartEntry> findByGameId(Long gameId);

    Optional<CartEntry> findByCustomerIdAndGameId(Long customerId, Long gameId);
}
