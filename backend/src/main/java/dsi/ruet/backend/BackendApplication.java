package dsi.ruet.backend;

import dsi.ruet.backend.config.RenderDatabaseUrlSupport;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class BackendApplication {

	public static void main(String[] args) {
		RenderDatabaseUrlSupport.applySpringDatasourceSystemPropertiesFromEnvironment();
		SpringApplication.run(BackendApplication.class, args);
	}

}