package dsi.ruet.backend.config;

import com.zaxxer.hikari.HikariDataSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import javax.sql.DataSource;
import java.net.URI;

/**
 * Production database configuration that handles Render.com's DATABASE_URL format.
 * Render provides URLs like: postgres://user:password@host:port/database
 * Spring Boot needs:         jdbc:postgresql://host:port/database  (+ separate user/pass)
 */
@Configuration
@Profile("prod")
public class DatabaseConfig {

    @Value("${spring.datasource.url:}")
    private String fallbackUrl;

    @Value("${spring.datasource.username:}")
    private String fallbackUsername;

    @Value("${spring.datasource.password:}")
    private String fallbackPassword;

    @Bean
    public DataSource dataSource() {
        String databaseUrl = System.getenv("DATABASE_URL");

        HikariDataSource dataSource = new HikariDataSource();

        if (databaseUrl != null && !databaseUrl.isEmpty()) {
            // Parse Render's postgres:// URL
            try {
                URI uri;
                if (databaseUrl.startsWith("postgres://")) {
                    uri = new URI("postgresql://" + databaseUrl.substring("postgres://".length()));
                } else {
                    uri = new URI(databaseUrl);
                }

                String host = uri.getHost();
                int port = uri.getPort() > 0 ? uri.getPort() : 5432;
                String dbName = uri.getPath().substring(1); // remove leading /
                String userInfo = uri.getUserInfo();
                String username = userInfo.split(":")[0];
                String password = userInfo.split(":")[1];

                String jdbcUrl = "jdbc:postgresql://" + host + ":" + port + "/" + dbName;

                dataSource.setJdbcUrl(jdbcUrl);
                dataSource.setUsername(username);
                dataSource.setPassword(password);

                // Render PostgreSQL requires SSL
                dataSource.addDataSourceProperty("sslmode", "require");

            } catch (Exception e) {
                throw new RuntimeException("Failed to parse DATABASE_URL: " + databaseUrl, e);
            }
        } else {
            // Fall back to standard Spring properties
            dataSource.setJdbcUrl(fallbackUrl);
            dataSource.setUsername(fallbackUsername);
            dataSource.setPassword(fallbackPassword);
        }

        dataSource.setDriverClassName("org.postgresql.Driver");
        return dataSource;
    }
}
