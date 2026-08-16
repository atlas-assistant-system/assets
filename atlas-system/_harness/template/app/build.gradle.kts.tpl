description = "Composition root: wires every ring together. Belongs to no layer."

plugins {
    application
}

dependencies {
    implementation(project(":domain"))
    implementation(project(":application"))
    implementation(project(":infrastructure"))
    implementation(project(":presentation"))

    testImplementation("dev.sharedkernel:sharedkernel-archunit:0.2.0")
}

application {
    mainModule = "{{MODULE_PACKAGE}}.app"
    mainClass = "{{MODULE_PACKAGE}}.app.Main"
    applicationDefaultJvmArgs = listOf(
        "-Xms96m",
        "-Xmx96m",
        "-Xss256k",
        "-XX:+UseSerialGC",
        "-XX:MaxMetaspaceSize=64m")
}
