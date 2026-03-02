package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.Wallet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

<<<<<<< HEAD
import java.util.Optional;

@Repository
public interface WalletRepository extends JpaRepository<Wallet, Long> {
    Optional<Wallet> findByUserId(Long userId);
=======
@Repository
public interface WalletRepository extends JpaRepository<Wallet, Long> {
>>>>>>> 519aad96173a138aa0de36bcf62195c81caef34b
}
