package {{MODULE_PACKAGE}}.app;

import java.io.IOException;
import java.lang.System.Logger.Level;
import java.util.logging.LogManager;
import sharedkernel.infrastructure.logging.LogEntryRenderers;

public final class Main {

    public static final int DEFAULT_PORT = 8080;

    private Main() {}

    public static void main(String[] args) throws IOException {
        configureLogging();

        var application = ModuleApplication.wire(LogEntryRenderers.forCurrentConsole()).start(DEFAULT_PORT);

        Runtime.getRuntime().addShutdownHook(new Thread(application::stop));

        System.getLogger("{{MODULE_PACKAGE}}")
            .log(Level.INFO, "{{MODULE_NAME}} listening on http://localhost:" + application.port());
    }

    private static void configureLogging() {
        try (var config = Main.class.getResourceAsStream("/logging.properties")) {
            if (config != null) {
                LogManager.getLogManager().readConfiguration(config);
            }
        } catch (IOException e) {
            System.getLogger("{{MODULE_PACKAGE}}").log(Level.WARNING, "Falling back to default logging.", e);
        }
    }
}
