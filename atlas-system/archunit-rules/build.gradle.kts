plugins {
    `java-library`
    `maven-publish`
    id("com.diffplug.spotless") version "8.9.0"
}

group = "dev.sharedkernel"
version = "0.2.0"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
    withSourcesJar()
}

repositories {
    mavenLocal()
    mavenCentral()
}

dependencies {
    api("com.tngtech.archunit:archunit-junit5:1.5.0")
    implementation("dev.sharedkernel:sharedkernel:0.7.0")

    testImplementation(platform("org.junit:junit-bom:5.11.4"))
    testImplementation("org.junit.jupiter:junit-jupiter")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
    testImplementation("org.assertj:assertj-core:3.26.3")
}

spotless {
    lineEndings = com.diffplug.spotless.LineEnding.UNIX
    java {
        target("src/**/*.java")
        eclipse().configFile("../shared-kernel/config/formatter.properties")
        importOrder("\\#", "")
        removeUnusedImports()
        trimTrailingWhitespace()
        endWithNewline()
    }
}

tasks.test {
    useJUnitPlatform()
}

publishing {
    publications {
        create<MavenPublication>("mavenJava") {
            from(components["java"])
        }
    }
}
