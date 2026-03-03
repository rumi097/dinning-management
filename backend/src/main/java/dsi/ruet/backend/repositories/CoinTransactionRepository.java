package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.CoinTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface CoinTransactionRepository extends JpaRepository<CoinTransaction, Long> {

    List<CoinTransaction> findBySenderIdOrReceiverId(Long senderId, Long receiverId);

    @Query("SELECT ct FROM CoinTransaction ct WHERE ct.type = dsi.ruet.backend.models.enums.TransactionType.TOPUP " +
           "AND ct.receiver.id IN :userIds " +
           "AND ct.createdAt >= :startOfDay AND ct.createdAt < :endOfDay")
    List<CoinTransaction> findTopUpsByReceiverIdsAndDate(
            @Param("userIds") List<Long> userIds,
            @Param("startOfDay") LocalDateTime startOfDay,
            @Param("endOfDay") LocalDateTime endOfDay);

    @Query("SELECT COALESCE(SUM(ct.amount), 0) FROM CoinTransaction ct WHERE ct.type = dsi.ruet.backend.models.enums.TransactionType.TOPUP " +
           "AND ct.receiver.id IN :userIds " +
           "AND ct.createdAt >= :startOfDay AND ct.createdAt < :endOfDay")
    Long sumTopUpsByReceiverIdsAndDate(
            @Param("userIds") List<Long> userIds,
            @Param("startOfDay") LocalDateTime startOfDay,
            @Param("endOfDay") LocalDateTime endOfDay);
}
