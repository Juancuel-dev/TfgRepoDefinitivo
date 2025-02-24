package com.repository;

import com.model.CartEntry;
import com.model.CartEntryDTO;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CartEntryDTORepository extends JpaRepository<CartEntry, Integer> {
    Optional<List<CartEntry>> findByCustomerId(Long costumerId);
}
