package sharedkernel.application.logging;

import java.util.Optional;

public final class CorrelationContext {

    private static final ScopedValue<String> CURRENT = ScopedValue.newInstance();

    private CorrelationContext() {}

    public static void runWith(String correlationId, Runnable action) {
        ScopedValue.where(CURRENT, correlationId).run(action);
    }

    public static Optional<String> current() {
        if (!CURRENT.isBound()) {
            return Optional.empty();
        }

        return Optional.of(CURRENT.get());
    }
}
