package com.main.ep.website.server

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import com.fasterxml.jackson.module.kotlin.registerKotlinModule
import jakarta.annotation.PostConstruct
import jakarta.servlet.ServletContext
import org.springframework.core.io.ClassPathResource
import org.springframework.stereotype.Service
import org.springframework.web.context.support.ServletContextResource
import java.io.InputStream

@Service
class ViteManifestService(
    private val objectMapper: ObjectMapper,
    private val servletContext: ServletContext
) {
  @PostConstruct
  fun init(){
    println("init service ViteManifestService")
  }

    private lateinit var manifest: Map<String, ViteManifestEntry>

    fun load(): Map<String, ViteManifestEntry> {
      val resource = ServletContextResource(
        servletContext,
        "/static/.vite/manifest.json"
      )

        return loadManifest(resource.inputStream)

    }


  fun loadManifest(input: InputStream): Map<String, ViteManifestEntry> {
    return objectMapper
      .registerKotlinModule()
      .readValue(input)
  }
}
