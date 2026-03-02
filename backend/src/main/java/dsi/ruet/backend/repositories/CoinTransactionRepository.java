package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.CoinTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Repository for CoinTransaction entity.
 * Handles top-up and other coin-based transaction queries.
 */
@Repository
public interface CoinTransactionRepository extends JpaRepository<CoinTransaction, Long> {

    /** All top-ups made by a specific sender (meal manager) */
    List<CoinTransaction> findBySenderIdAndType(Long senderId, String type);

    /** All coin transactions where a user is sender or receiver */
    List<CoinTransaction> findBySenderIdOrReceiverId(Long senderId, Long receiverId);

    /** Top-up history: all TOPUP transactions sent by this manager, newest first */
    List<CoinTransaction> findBySenderIdAndTypeOrderByCreatedAtDesc(Long senderId, String type);

    /** Total amount topped up by a manager on a specific day */
    @Query("SELECT COALESCE(SUM(ct.amount), 0) FROM CoinTransaction ct " +
           "WHERE ct.sender.id = :senderId AND ct.type = 'TOPUP' " +
           "AND ct.createdAt >= :dayStart AND ct.createdAt < :dayEnd")
    BigDecimal sumTopUpBySenderAndDay(
            @Param("senderId") Long senderId,
            @Param("dayStart") LocalDateTime dayStart,
            @Param("dayEnd") LocalDateTime dayEnd);

    /** All TOPUP transactions by a manager within a date range, newest first */
    @Query("SELECT ct FROM CoinTransaction ct " +
           "WHERE ct.sender.id = :senderId AND ct.type = 'TOPUP' " +
           "AND ct.createdAt >= :start AND ct.createdAt < :end " +
           "ORDER BY ct.createdAt DESC")
    List<CoinTransaction> findTopUpsBySenderAndDateRange(
            @Param("senderId") Long senderId,
            @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end);

    /** Count of TOPUP transactions by a manager on a specific day */
    @Query("SELECT COUNT(ct) FROM CoinTransaction ct " +
           "WHERE ct.sender.id = :senderId AND ct.type = 'TOPUP' " +
           "AND ct.createdAt >= :dayStart AND ct.createdAt < :dayEnd")
    long countTopUpsBySenderAndDay(
            @Param("senderId") Long senderId,
            @Param("dayStart") LocalDateTime dayStart,
            @Param("dayEnd") LocalDateTime dayEnd);

    /** All REFUND transactions by a manager within a date range */
    @Query("SELECT ct FROM CoinTransaction ct " +
           "WHERE ct.sender.id = :senderId AND ct.type = 'REFUND' " +
           "AND ct.createdAt >= :start AND ct.createdAt < :end " +
           "ORDER BY ct.createdAt DESC")
    List<CoinTransaction> findRefundsBySenderAndDateRange(
            @Param("senderId") Long senderId,
            @Param("start") LocalDateTime start,
            @Param("end") LocalDateTime end);
}
