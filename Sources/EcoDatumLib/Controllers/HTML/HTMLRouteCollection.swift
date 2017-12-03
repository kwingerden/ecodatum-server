import AuthProvider
import Vapor

final class HTMLRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  init(_ drop: Droplet) {
    self.drop = drop
  }
  
  func build(_ builder: RouteBuilder) throws {
    
    let html = builder.grouped("html")
    html.group(middleware: []) {
      builder in
      builder.resource("hello", HTMLHelloController(drop))
    }
    
  }
  
}

