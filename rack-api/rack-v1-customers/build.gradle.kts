plugins {
    kotlin("jvm") version "1.9.22"
    kotlin("plugin.spring")
}

//group = "com.main.ep.rack.v1.customers"
//version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}


dependencies {
    implementation(project(":core"))
    implementation(libs.spring.web)
    implementation(libs.spring.webmvc)
    implementation(libs.spring.context)
    implementation(libs.jackson.databind)
    implementation(libs.micrometer.core)
    implementation(libs.micrometer.commons)
    implementation(libs.jakarta.validation.api)
    implementation(kotlin("stdlib"))
}

tasks.test {
    useJUnitPlatform()
}
kotlin {
    jvmToolchain(21)
}
