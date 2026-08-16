package {{MODULE_PACKAGE}}.infrastructure.persistence;

import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import sharedkernel.domain.guards.StringGuard;
import sharedkernel.infrastructure.persistence.PersistenceException;

public final class SqliteConnections {

    private SqliteConnections() {}

    public static Connection openForContext(Path databaseDirectory, String boundedContext) {
        StringGuard.notBlank(boundedContext, "boundedContext");

        var file = databaseDirectory.resolve(boundedContext + ".db");

        try {
            var connection = DriverManager.getConnection("jdbc:sqlite:" + file);
            connection.setAutoCommit(false);

            return connection;
        } catch (SQLException e) {
            throw new PersistenceException("Failed to open the database for " + boundedContext, e);
        }
    }
}
