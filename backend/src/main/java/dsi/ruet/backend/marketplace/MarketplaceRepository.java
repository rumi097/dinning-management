package dsi.ruet.backend.marketplace;

import dsi.ruet.backend.models.enums.MarketplacePostStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface MarketplaceRepository extends JpaRepository<MarketplacePost, Long> {

    /** Find all posts with a given status for a specific hall (via token → meal → hall). */
    @Query("SELECT mp FROM MarketplacePost mp " +
            "JOIN FETCH mp.token t " +
            "JOIN FETCH t.meal m " +
            "JOIN FETCH mp.seller s " +
            "LEFT JOIN FETCH mp.buyer " +
            "WHERE mp.status = :status AND m.hall.id = :hallId " +
            "ORDER BY mp.createdAt DESC")
    List<MarketplacePost> findByStatusAndHallId(
            @Param("status") MarketplacePostStatus status,
            @Param("hallId") Long hallId);

    /** Find posts by seller with specific statuses. */
    @Query("SELECT mp FROM MarketplacePost mp " +
            "JOIN FETCH mp.token t " +
            "JOIN FETCH t.meal m " +
            "JOIN FETCH mp.seller " +
            "LEFT JOIN FETCH mp.buyer " +
            "WHERE mp.seller.id = :sellerId AND mp.status IN :statuses " +
            "ORDER BY mp.createdAt DESC")
    List<MarketplacePost> findBySellerIdAndStatusIn(
            @Param("sellerId") Long sellerId,
            @Param("statuses") List<MarketplacePostStatus> statuses);

    /** Find pending purchases by buyer. */
    @Query("SELECT mp FROM MarketplacePost mp " +
            "JOIN FETCH mp.token t " +
            "JOIN FETCH t.meal m " +
            "JOIN FETCH mp.seller " +
            "LEFT JOIN FETCH mp.buyer " +
            "WHERE mp.buyer.id = :buyerId AND mp.status = :status " +
            "ORDER BY mp.createdAt DESC")
    List<MarketplacePost> findByBuyerIdAndStatus(
            @Param("buyerId") Long buyerId,
            @Param("status") MarketplacePostStatus status);

    /** Find PENDING posts that have exceeded the timeout window. */
    @Query("SELECT mp FROM MarketplacePost mp " +
            "JOIN FETCH mp.token t " +
            "WHERE mp.status = :status AND mp.buyerRequestedAt < :cutoff")
    List<MarketplacePost> findTimedOutPendingPosts(
            @Param("status") MarketplacePostStatus status,
            @Param("cutoff") LocalDateTime cutoff);

    /** Check if an active (OPEN or PENDING) post exists for a token. */
    boolean existsByTokenIdAndStatusIn(Long tokenId, List<MarketplacePostStatus> statuses);

    /** Get the active post for a specific token. */
    Optional<MarketplacePost> findFirstByTokenIdAndStatusIn(
            Long tokenId, List<MarketplacePostStatus> statuses);
}
