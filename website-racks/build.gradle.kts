plugins {
    kotlin("jvm")
}

//group = "com.main.ep.rack"
//version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}
val SpringFrameworkVersion = properties["SpringFrameworkVersion"]
val IOmicrometerVersion = properties["IOmicrometerVersion"]
val JacksonDataBindVersion = properties["JacksonDataBindVersion"]
dependencies {

    testImplementation("org.jetbrains.kotlin:kotlin-test")
    implementation("org.springframework:spring-context:$SpringFrameworkVersion")

    implementation("org.springframework:spring-web:$SpringFrameworkVersion")
    implementation("org.springframework:spring-webmvc:$SpringFrameworkVersion")
    implementation("io.micrometer:micrometer-core:$IOmicrometerVersion")
    implementation("io.micrometer:micrometer-commons:$IOmicrometerVersion")
    implementation("com.fasterxml.jackson.core:jackson-databind:$JacksonDataBindVersion")
    implementation("jakarta.validation:jakarta.validation-api:3.0.2")
    implementation(project(":core"))
    implementation(project(":rack-db:rack-server-postgres"))


}

tasks.test {
    useJUnitPlatform()
}
kotlin {
    jvmToolchain(21)
}
