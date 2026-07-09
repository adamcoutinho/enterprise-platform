plugins {
    kotlin("jvm")
  kotlin("plugin.spring")
}

group = "com.main.ep.website.server"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {


  // ============================================================
  // Spring Framework
  // ============================================================

  implementation(libs.spring.context)
  implementation(libs.spring.web)
  implementation(libs.spring.webmvc)
  implementation(libs.spring.context.support)


  // ============================================================
  // Jackson JSON
  // ============================================================

  implementation(libs.jackson.core)
  implementation(libs.jackson.databind)
  implementation(libs.jackson.annotations)
  implementation(libs.jackson.module.kotlin)


  // ============================================================
  // Jakarta Validation / Annotation
  // ============================================================

  implementation(libs.jakarta.validation.api)
  implementation(libs.jakarta.annotation.api)


  // ============================================================
  // JSTL para JSP
  // Runtime fornecido pela aplicação web
  // ============================================================

  implementation(libs.jakarta.jstl)


  // ============================================================
  // Servlet / JSP API
  //
  // Tomcat fornece em runtime
  // ============================================================

  compileOnly(libs.jakarta.servlet.api)
  compileOnly(libs.jakarta.servlet.jsp.api)


  // ============================================================
  // Micrometer
  // ============================================================

  implementation(libs.micrometer.core)
  implementation(libs.micrometer.commons)


  // ============================================================
  // Testes
  // ============================================================

  testImplementation(libs.kotlin.test)
    implementation(kotlin("stdlib"))

}

tasks.test {
    useJUnitPlatform()
}
kotlin {
    jvmToolchain(21)
}
