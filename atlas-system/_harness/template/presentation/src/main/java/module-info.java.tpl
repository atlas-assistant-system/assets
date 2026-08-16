module {{MODULE_PACKAGE}}.presentation {

    requires jdk.httpserver;
    requires sharedkernel;
    requires {{MODULE_PACKAGE}}.application;
    requires {{MODULE_PACKAGE}}.domain;
}
