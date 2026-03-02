package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.TokenTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TokenTransactionRepository extends JpaRepository<TokenTransaction, Long> {

    List<TokenTransaction> findByTokenId(Long tokenId);

    /** Get all token transactions where user is sender or receiver. */
    List<TokenTransaction> findBySenderIdOrReceiverId(Long senderId, Long receiverId);
}
