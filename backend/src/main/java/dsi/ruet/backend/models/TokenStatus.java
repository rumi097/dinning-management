package dsi.ruet.backend.models;

/**
 * Represents the lifecycle states of a meal token.
 */
public enum TokenStatus {
    /** Token is active and can be used or transferred */
    ACTIVE,
    /** Token has been used (meal served) */
    USED,
    /** Token is listed on the marketplace for sale */
    LISTED,
    /** Token has been cancelled */
    CANCELLED
}
