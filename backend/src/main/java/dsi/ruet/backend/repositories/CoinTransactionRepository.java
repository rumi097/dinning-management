package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.CoinTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CoinTransactionRepository extends JpaRepository<CoinTransaction, Long> {

    /** Get all transactions where the user is sender or receiver. */
    List<CoinTransaction> findBySenderIdOrReceiverId(Long senderId, Long receiverId);
}
