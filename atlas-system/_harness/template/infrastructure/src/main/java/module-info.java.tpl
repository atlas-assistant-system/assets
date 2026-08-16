module {{MODULE_PACKAGE}}.infrastructure {

    requires java.sql;
    requires sharedkernel;
    requires {{MODULE_PACKAGE}}.application;
    requires {{MODULE_PACKAGE}}.domain;

    exports {{MODULE_PACKAGE}}.infrastructure.persistence;
}
