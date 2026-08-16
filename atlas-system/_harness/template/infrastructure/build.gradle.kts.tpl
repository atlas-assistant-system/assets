description = "Infrastructure ring: SQLite persistence, outbound clients and adapters."

dependencies {
    api(project(":application"))
    runtimeOnly("org.xerial:sqlite-jdbc:3.47.1.0")
    testImplementation("org.xerial:sqlite-jdbc:3.47.1.0")
}
