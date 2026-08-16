plugins {
    id("com.diffplug.spotless") version "8.9.0" apply false
}

subprojects {
    apply(plugin = "java-library")
    apply(plugin = "com.diffplug.spotless")

    repositories {
        mavenLocal()
        mavenCentral()
    }

    extensions.configure<JavaPluginExtension> {
        toolchain {
            languageVersion = JavaLanguageVersion.of(25)
        }
    }

    dependencies {
        "implementation"("dev.sharedkernel:sharedkernel:0.11.0")

        "testImplementation"(platform("org.junit:junit-bom:5.11.4"))
        "testImplementation"("org.junit.jupiter:junit-jupiter")
        "testRuntimeOnly"("org.junit.platform:junit-platform-launcher")
        "testImplementation"("org.assertj:assertj-core:3.26.3")
        "testImplementation"("org.mockito:mockito-core:5.14.2")
    }

    extensions.configure<com.diffplug.gradle.spotless.SpotlessExtension> {
        lineEndings = com.diffplug.spotless.LineEnding.UNIX
        java {
            target("src/**/*.java")
            eclipse().configFile(rootProject.file("config/formatter.properties"))
            importOrder("\\#", "")
            removeUnusedImports()
            trimTrailingWhitespace()
            endWithNewline()
        }
    }

    tasks.withType<Test>().configureEach {
        useJUnitPlatform()
    }

    tasks.withType<JavaExec>().configureEach {
        jvmArgs(
            "-Xms96m",
            "-Xmx96m",
            "-Xss256k",
            "-XX:+UseSerialGC",
            "-XX:MaxMetaspaceSize=64m")
    }
}
