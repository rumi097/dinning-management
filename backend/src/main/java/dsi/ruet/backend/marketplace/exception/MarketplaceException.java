package dsi.ruet.backend.marketplace.exception;

public class MarketplaceException extends RuntimeException {

    public MarketplaceException(String message) {
        super(message);
    }

    public MarketplaceException(String message, Throwable cause) {
        super(message, cause);
    }
}
