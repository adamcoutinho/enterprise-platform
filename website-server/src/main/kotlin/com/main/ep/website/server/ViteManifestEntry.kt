package com.main.ep.website.server

import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonProperty
@JsonIgnoreProperties(ignoreUnknown = true)
data class ViteManifestEntry(

  val file: String,

  val name: String? = null,

  val css: List<String>?=null,

  val src: String? = null,

  val isEntry: Boolean? = null,

  val isDynamicEntry: Boolean? = null,

  val imports: List<String>? = null,

  val dynamicImports: List<String>? = null
)
