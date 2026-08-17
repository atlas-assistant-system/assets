package sharedkernel.infrastructure.console;

import java.util.ArrayList;
import java.util.List;
import sharedkernel.domain.guards.ObjectGuard;
import sharedkernel.domain.guards.StringGuard;
import sharedkernel.infrastructure.logging.LogEntryRenderers;

public final class StartupBanner {

    public static final String ESC = String.valueOf((char) 27);
    public static final String RESET = ESC + "[0m";
    public static final String DIM = ESC + "[90m";
    public static final String DEEP_NAVY = rgb(11, 31, 58);
    public static final String PRIMARY_BLUE = rgb(36, 107, 253);
    public static final String CYAN = rgb(54, 197, 240);

    private final String name;
    private final List<Entry> entries = new ArrayList<>();

    private String color = PRIMARY_BLUE;
    private boolean colored = LogEntryRenderers.colorIsSupported();

    private StartupBanner(String name) {
        this.name = name;
    }

    public static StartupBanner named(String name) {
        return new StartupBanner(StringGuard.notBlank(name, "name"));
    }

    public static String rgb(int red, int green, int blue) {
        return ESC + "[38;2;" + red + ";" + green + ";" + blue + "m";
    }

    public static String jdkVersion() {
        return Runtime.version().toString();
    }

    public static String processId() {
        return String.valueOf(ProcessHandle.current().pid());
    }

    public StartupBanner colored(String ansiColor) {
        this.color = ObjectGuard.notNull(ansiColor, "ansiColor");

        return this;
    }

    public StartupBanner withColor(boolean enabled) {
        this.colored = enabled;

        return this;
    }

    public StartupBanner withoutColor() {
        return withColor(false);
    }

    public StartupBanner with(String label, String value) {
        StringGuard.notBlank(label, "label");
        ObjectGuard.notNull(value, "value");

        entries.add(new Entry(label, value));

        return this;
    }

    public String render() {
        var banner = new StringBuilder(System.lineSeparator());

        for (var row : AsciiFont.render(name)) {
            banner.append(paint(row, color)).append(System.lineSeparator());
        }

        if (entries.isEmpty()) {
            return banner.toString();
        }

        banner.append(System.lineSeparator());

        var width = entries.stream().mapToInt(entry -> entry.label().length()).max().orElse(0);

        for (var entry : entries) {
            banner.append("  ").append(paint(pad(entry.label(), width), DIM));
            banner.append("  ").append(entry.value()).append(System.lineSeparator());
        }

        return banner.append(System.lineSeparator()).toString();
    }

    private String paint(String text, String ansiColor) {
        if (!colored) {
            return text;
        }

        return ansiColor + text + RESET;
    }

    private static String pad(String label, int width) {
        return label + " ".repeat(width - label.length());
    }

    private record Entry(String label, String value) {}
}
