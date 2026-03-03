package dsi.ruet.backend.marketplace;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Scheduler that automatically expires PENDING marketplace buy requests
 * after the 15-minute timeout window.
 *
 * Runs every 60 seconds. Posts that have been PENDING for > 15 minutes
 * are rolled back to OPEN status so other buyers can request them.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class MarketplaceScheduler {

    private final MarketplaceService marketplaceService;

    @Scheduled(fixedRate = 60_000) // every 60 seconds
    public void expireTimedOutRequests() {
        int expired = marketplaceService.expireTimedOutRequests();
        if (expired > 0) {
            log.info("Marketplace scheduler: expired {} timed-out requests", expired);
        }
    }
}
