package sharedkernel.infrastructure.logging;

import java.time.ZoneId;
import sharedkernel.application.logging.LogEntryRenderer;
import sharedkernel.application.logging.PlainLogEntryRenderer;

public final class LogEntryRenderers {

    private LogEntryRenderers() {}

    public static LogEntryRenderer forCurrentConsole() {
        return forConsole(System.console() != null, ZoneId.systemDefault());
    }

    public static LogEntryRenderer forConsole(boolean colorSupported, ZoneId zone) {
        if (!colorSupported) {
            return new PlainLogEntryRenderer();
        }

        return new ConsoleLogEntryRenderer(zone);
    }
}
