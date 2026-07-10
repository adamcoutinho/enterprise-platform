plugins {
    kotlin("jvm") version "1.9.22"
    war
}

group = "com.main.ep.website"
version = ""

repositories {
    mavenCentral()
}

dependencies {
    compileOnly(libs.jakarta.jstl)
    compileOnly(project(path = ":website-server"))
    compileOnly(project(path = ":rack-api:rack-v1-customers"))
    compileOnly(project(path = ":rack-api:rack-v1-error-handler"))
    compileOnly(project(path = ":rack-db:rack-server-postgres"))
    compileOnly(project(":website-racks"))


}

tasks.test {
    useJUnitPlatform()
}

kotlin {
    jvmToolchain(21)
}
