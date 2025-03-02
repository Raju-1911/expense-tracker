import javax.annotation.PreDestroy;
import ch.qos.logback.classic.LoggerContext;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SmartspendApplication {

    public static void main(String[] args) {
        SpringApplication.run(SmartspendApplication.class, args);
    }

    @PreDestroy
    public void shutdownLogger() {
        LoggerContext loggerContext = (LoggerContext) LoggerFactory.getILoggerFactory();
        loggerContext.stop();
        System.out.println("Logback logger context stopped.");
    }
}
