package {{MODULE_PACKAGE}}.app;

import java.io.IOException;
import java.lang.System.Logger.Level;
import java.util.logging.LogManager;
import sharedkernel.infrastructure.logging.LogEntryRenderers;

public final class Main {

    private Main() {}

    public static void main(String[] args) {
        configureLogging();

        ModuleApplication.wire(LogEntryRenderers.forCurrentConsole());

        System.getLogger("{{MODULE_PACKAGE}}").log(Level.INFO, "{{MODULE_NAME}} started.");
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
