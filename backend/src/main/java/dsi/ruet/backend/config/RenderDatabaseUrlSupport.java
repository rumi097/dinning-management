package dsi.ruet.backend.config;

import java.net.URI;

/**
 * Render's managed Postgres typically exposes a {@code DATABASE_URL} env var using the
 * {@code postgres://user:pass@host:port/db} scheme. Spring Boot's datasource expects a JDBC URL.
 *
 * This helper converts non-JDBC Postgres URLs into {@code spring.datasource.*} system properties
 * early (before {@code SpringApplication.run}) so datasource auto-configuration can succeed.
 */
public final class RenderDatabaseUrlSupport {

	private RenderDatabaseUrlSupport() {
	}

	public static void applySpringDatasourceSystemPropertiesFromEnvironment() {
		// Respect explicit JVM -D overrides.
		if (isNonBlank(System.getProperty("spring.datasource.url"))) {
			return;
		}

		String springDatasourceUrl = getenv("SPRING_DATASOURCE_URL");
		String jdbcDatabaseUrl = getenv("JDBC_DATABASE_URL");
		String databaseUrl = getenv("DATABASE_URL");

		String candidate = firstNonBlank(springDatasourceUrl, jdbcDatabaseUrl, databaseUrl);
		if (!isNonBlank(candidate)) {
			return;
		}

		String trimmedCandidate = candidate.trim();

		// If already a JDBC URL, nothing to do.
		if (startsWithIgnoreCase(trimmedCandidate, "jdbc:")) {
			// Still try to fill missing username/password from DATABASE_URL, if available.
			applyUsernamePasswordFromDatabaseUrlIfMissing(databaseUrl);
			return;
		}

		ParsedPostgresUrl parsed = tryParsePostgresUrl(trimmedCandidate);
		if (parsed == null && isNonBlank(databaseUrl) && !trimmedCandidate.equals(databaseUrl.trim())) {
			parsed = tryParsePostgresUrl(databaseUrl.trim());
		}
		if (parsed == null) {
			return;
		}

		System.setProperty("spring.datasource.url", parsed.jdbcUrl());
		applyUsernamePasswordIfMissing(parsed);
	}

	private static void applyUsernamePasswordFromDatabaseUrlIfMissing(String databaseUrl) {
		if (!isNonBlank(databaseUrl)) {
			return;
		}
		ParsedPostgresUrl parsed = tryParsePostgresUrl(databaseUrl.trim());
		if (parsed == null) {
			return;
		}
		applyUsernamePasswordIfMissing(parsed);
	}

	private static void applyUsernamePasswordIfMissing(ParsedPostgresUrl parsed) {
		if (isNonBlank(parsed.username()) && !hasExplicitDatasourceUsername()) {
			System.setProperty("spring.datasource.username", parsed.username());
		}
		if (parsed.password() != null && !hasExplicitDatasourcePassword()) {
			System.setProperty("spring.datasource.password", parsed.password());
		}
	}

	private static boolean hasExplicitDatasourceUsername() {
		return isNonBlank(System.getProperty("spring.datasource.username")) || isNonBlank(getenv("SPRING_DATASOURCE_USERNAME"));
	}

	private static boolean hasExplicitDatasourcePassword() {
		return isNonBlank(System.getProperty("spring.datasource.password")) || isNonBlank(getenv("SPRING_DATASOURCE_PASSWORD"));
	}

	private static String getenv(String name) {
		return System.getenv(name);
	}

	private static String firstNonBlank(String... values) {
		for (String value : values) {
			if (isNonBlank(value)) {
				return value;
			}
		}
		return null;
	}

	private static boolean isNonBlank(String value) {
		return value != null && !value.trim().isEmpty();
	}

	private static boolean startsWithIgnoreCase(String value, String prefix) {
		if (value == null || prefix == null) {
			return false;
		}
		if (value.length() < prefix.length()) {
			return false;
		}
		return value.regionMatches(true, 0, prefix, 0, prefix.length());
	}

	private static boolean containsIgnoreCase(String haystack, String needle) {
		if (haystack == null || needle == null) {
			return false;
		}
		return haystack.toLowerCase().contains(needle.toLowerCase());
	}

	private static boolean isLikelyRenderEnvironment() {
		// Render injects various RENDER_* env vars. This is intentionally defensive.
		return isNonBlank(getenv("RENDER")) || isNonBlank(getenv("RENDER_SERVICE_ID")) || isNonBlank(getenv("RENDER_EXTERNAL_URL"))
				|| isNonBlank(getenv("RENDER_GIT_COMMIT")) || isNonBlank(getenv("RENDER_INSTANCE_ID"));
	}

	private static ParsedPostgresUrl tryParsePostgresUrl(String url) {
		URI uri;
		try {
			uri = URI.create(url);
		} catch (IllegalArgumentException ex) {
			return null;
		}

		String scheme = uri.getScheme();
		if (scheme == null) {
			return null;
		}
		String normalizedScheme = scheme.toLowerCase();
		if (!normalizedScheme.equals("postgres") && !normalizedScheme.equals("postgresql")) {
			return null;
		}

		String host = uri.getHost();
		if (!isNonBlank(host)) {
			return null;
		}
		int port = uri.getPort();

		String path = uri.getPath();
		String database = "";
		if (path != null && !path.isBlank()) {
			database = path.startsWith("/") ? path.substring(1) : path;
		}

		StringBuilder jdbcUrl = new StringBuilder();
		jdbcUrl.append("jdbc:postgresql://");
		if (host.contains(":")) {
			jdbcUrl.append("[").append(host).append("]");
		} else {
			jdbcUrl.append(host);
		}
		if (port > 0) {
			jdbcUrl.append(":").append(port);
		}
		jdbcUrl.append("/").append(database);

		String query = uri.getQuery();
		String finalQuery = query;
		if (isLikelyRenderEnvironment() && !containsIgnoreCase(finalQuery, "sslmode=")) {
			if (isNonBlank(finalQuery)) {
				finalQuery = finalQuery + "&sslmode=require";
			} else {
				finalQuery = "sslmode=require";
			}
		}
		if (isNonBlank(finalQuery)) {
			jdbcUrl.append("?").append(finalQuery);
		}

		String username = null;
		String password = null;
		String userInfo = uri.getUserInfo();
		if (isNonBlank(userInfo)) {
			String[] parts = userInfo.split(":", 2);
			username = parts[0];
			password = (parts.length > 1) ? parts[1] : "";
		}

		return new ParsedPostgresUrl(jdbcUrl.toString(), username, password);
	}

	private record ParsedPostgresUrl(String jdbcUrl, String username, String password) {
	}
}