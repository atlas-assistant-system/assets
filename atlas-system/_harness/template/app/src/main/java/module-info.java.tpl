module {{MODULE_PACKAGE}}.app {

    requires java.logging;
    requires sharedkernel;
    requires {{MODULE_PACKAGE}}.application;
    requires {{MODULE_PACKAGE}}.domain;
    requires {{MODULE_PACKAGE}}.infrastructure;
    requires {{MODULE_PACKAGE}}.presentation;
}
