package dsi.ruet.backend.config;

import dsi.ruet.backend.models.Hall;
import dsi.ruet.backend.repositories.HallRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private HallRepository hallRepository;

    @Override
    public void run(String... args) throws Exception {
        // Initialize dummy halls if they don't exist
        if (hallRepository.count() == 0) {
            hallRepository.save(new Hall(null, "Tanti Hall"));
            hallRepository.save(new Hall(null, "Rajshahi Hall"));
            hallRepository.save(new Hall(null, "Chittagong Hall"));
            hallRepository.save(new Hall(null, "Sylhet Hall"));
            hallRepository.save(new Hall(null, "Khulna Hall"));
            System.out.println("Dummy halls initialized successfully");
        }
    }
}
