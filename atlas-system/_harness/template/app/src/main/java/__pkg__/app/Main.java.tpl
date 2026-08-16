package {{MODULE_PACKAGE}}.app;

import java.io.IOException;
import java.lang.System.Logger.Level;
import java.util.logging.LogManager;
import sharedkernel.application.cqrs.SimpleCommandBus;
import sharedkernel.application.cqrs.SimpleQueryBus;
import sharedkernel.application.events.SimpleDomainEventPublisher;
import sharedkernel.application.logging.LogEntryRenderer;
import sharedkernel.infrastructure.logging.LogEntryRenderers;

public final class Main {

    private Main() {}

    public static void main(String[] args) {
        configureLogging();

        var renderer = LogEntryRenderers.forCurrentConsole();
        var events = new SimpleDomainEventPublisher();
        var commands = new SimpleCommandBus();
        var queries = new SimpleQueryBus();

        registerHandlers(commands, queries, events, renderer);

        System.getLogger("{{MODULE_PACKAGE}}").log(Level.INFO, "{{MODULE_NAME}} started.");
    }

    private static void registerHandlers(
        SimpleCommandBus commands,
        SimpleQueryBus queries,
        SimpleDomainEventPublisher events,
        LogEntryRenderer renderer) {}

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
