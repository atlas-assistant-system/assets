module {{MODULE_PACKAGE}} {

    requires java.sql;
    requires org.xerial.sqlitejdbc;
    requires sharedkernel;

    exports {{MODULE_PACKAGE}}.domain;
}
