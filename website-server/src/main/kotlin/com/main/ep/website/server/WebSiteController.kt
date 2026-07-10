package com.main.ep.website.server

import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.servlet.ModelAndView

@Controller
class WebSiteController(private val manifestContextService: ViteManifestService) {

  // 1. Alterado para "/" para interceptar a inicialização da aplicação
  @GetMapping("/")
  fun get(): ModelAndView {

    println("=========================================")
    println("ENTROU NO CONTROLLER COM SUCESSO!")
    println("=========================================")

    // 2. CORRIGIDO: Passe apenas o nome do arquivo "index".
    // O ViewResolver se encarrega de achar em /WEB-INF/spa-pages/index.jsp
    val mv = ModelAndView("index")

    // Sua lógica do Vite (injetar JS e CSS dinâmicos da build no JSP)
    val parameters = manifestContextService.load()

    parameters["index.html"]?.let { value ->
      mv.addObject("js_file", value.file)
      value.css?.firstOrNull()?.let { css ->
        mv.addObject("css_file", css)
      }
    }

    return mv
  }
}
