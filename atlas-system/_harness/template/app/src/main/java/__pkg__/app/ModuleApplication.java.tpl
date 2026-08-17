package {{MODULE_PACKAGE}}.app;

import sharedkernel.application.cqrs.SimpleCommandBus;
import sharedkernel.application.cqrs.SimpleQueryBus;
import sharedkernel.application.events.SimpleDomainEventPublisher;
import sharedkernel.application.logging.LogEntryRenderer;

public final class ModuleApplication {

    private final SimpleCommandBus commands;
    private final SimpleQueryBus queries;
    private final SimpleDomainEventPublisher events;

    private ModuleApplication(
        SimpleCommandBus commands, SimpleQueryBus queries, SimpleDomainEventPublisher events) {
        this.commands = commands;
        this.queries = queries;
        this.events = events;
    }

    public static ModuleApplication wire(LogEntryRenderer renderer) {
        var events = new SimpleDomainEventPublisher();
        var commands = new SimpleCommandBus();
        var queries = new SimpleQueryBus();

        registerHandlers(commands, queries, events, renderer);

        return new ModuleApplication(commands, queries, events);
    }

    public SimpleCommandBus commands() {
        return commands;
    }

    public SimpleQueryBus queries() {
        return queries;
    }

    public SimpleDomainEventPublisher events() {
        return events;
    }

    private static void registerHandlers(
        SimpleCommandBus commands,
        SimpleQueryBus queries,
        SimpleDomainEventPublisher events,
        LogEntryRenderer renderer) {}
}
