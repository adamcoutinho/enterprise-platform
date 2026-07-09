    package com.main.ep.website.server

    import org.springframework.stereotype.Controller
    import org.springframework.web.bind.annotation.GetMapping
    import org.springframework.web.bind.annotation.RequestMapping

    @Controller
    class HomeController(private val manifestContextService: ViteManifestService) {
//      @RequestMapping("/{path:[^\\.]*}")
//      fun redirect(): String {
//        println("redirecionamento de pagina")
//        return "forward:/index.jsp"
//      }

      @RequestMapping("/signin")
      fun redirectSignin(): String {
        println("redirecionamento de pagina")

        this.manifestContextService.load()

        return "forward:/index.jsp"
      }
//
//
//        @RequestMapping(value = ["/develophub", "/develophub/**"],
////            produces = ["text/html"],
//            consumes = ["text/html"]
//        )
//        fun admin(): String {
//            return "forward:/static/site-develophub/index.html"
//        }
//


      @GetMapping
      fun get(){

      }
    }
