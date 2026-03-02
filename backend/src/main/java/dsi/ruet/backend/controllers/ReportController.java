package dsi.ruet.backend.controllers;

import dsi.ruet.backend.dto.ApiResponse;
import dsi.ruet.backend.dto.manager.SalesReportResponse;
import dsi.ruet.backend.dto.manager.SalesSummaryResponse;
import dsi.ruet.backend.dto.manager.WalletTopupReportResponse;
import dsi.ruet.backend.services.ReportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/reports")
@CrossOrigin(origins = "*", maxAge = 3600)
public class ReportController {

    @Autowired
    private ReportService reportService;

    /**
     * GET /reports/sales?date=YYYY-MM-DD — Sales report for a given date
     * Returns token sales breakdown by meal type with counts and revenue.
     * Scoped to the authenticated meal manager's hall.
     */
    @GetMapping("/sales")
    @PreAuthorize("hasRole('MEAL_MANAGER')")
    public ResponseEntity<ApiResponse<SalesReportResponse>> getSalesReport(
            Authentication authentication,
            @RequestParam String date) {
        String email = authentication.getName();
        ApiResponse<SalesReportResponse> response = reportService.getSalesReport(email, date);
        return ResponseEntity.ok(response);
    }

    /**
     * GET /reports/wallet-topups?date=YYYY-MM-DD — Wallet top-up report for a given date
     * Returns all top-up transactions for students in the manager's hall on the given date.
     * Scoped to the authenticated meal manager's hall.
     */
    @GetMapping("/wallet-topups")
    @PreAuthorize("hasRole('MEAL_MANAGER')")
    public ResponseEntity<ApiResponse<WalletTopupReportResponse>> getWalletTopupReport(
            Authentication authentication,
            @RequestParam String date) {
        String email = authentication.getName();
        ApiResponse<WalletTopupReportResponse> response = reportService.getWalletTopupReport(email, date);
        return ResponseEntity.ok(response);
    }

    /**
     * GET /reports/sales-summary — Get sales summary (today + tomorrow)
     * Returns token sales counts and revenue for today and tomorrow,
     * plus meal configuration details for tomorrow.
     * Scoped to the authenticated meal manager's hall.
     */
    @GetMapping("/sales-summary")
    @PreAuthorize("hasRole('MEAL_MANAGER')")
    public ResponseEntity<ApiResponse<SalesSummaryResponse>> getSalesSummary(
            Authentication authentication) {
        String email = authentication.getName();
        ApiResponse<SalesSummaryResponse> response = reportService.getSalesSummary(email);
        return ResponseEntity.ok(response);
    }
}
