package config;

import javax.annotation.PreDestroy;
import javax.sql.DataSource;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.stereotype.Component;

@Component
public class DatabaseShutdownHook {

    private final DataSource dataSource;

    public DatabaseShutdownHook(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @PreDestroy
    public void shutdown() {
        if (dataSource instanceof HikariDataSource) {
            ((HikariDataSource) dataSource).close();
            System.out.println("HikariCP DataSource closed.");
        }
    }
}
