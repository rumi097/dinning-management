package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.CoinTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface CoinTransactionRepository extends JpaRepository<CoinTransaction, Long> {

    @Query("SELECT ct FROM CoinTransaction ct WHERE ct.type = 'TOP_UP' " +
           "AND ct.receiverId IN :userIds " +
           "AND ct.createdAt >= :startOfDay AND ct.createdAt < :endOfDay")
    List<CoinTransaction> findTopUpsByReceiverIdsAndDate(
            @Param("userIds") List<Long> userIds,
            @Param("startOfDay") LocalDateTime startOfDay,
            @Param("endOfDay") LocalDateTime endOfDay);

    @Query("SELECT COALESCE(SUM(ct.amount), 0) FROM CoinTransaction ct WHERE ct.type = 'TOP_UP' " +
           "AND ct.receiverId IN :userIds " +
           "AND ct.createdAt >= :startOfDay AND ct.createdAt < :endOfDay")
    BigDecimal sumTopUpsByReceiverIdsAndDate(
            @Param("userIds") List<Long> userIds,
            @Param("startOfDay") LocalDateTime startOfDay,
            @Param("endOfDay") LocalDateTime endOfDay);
}
