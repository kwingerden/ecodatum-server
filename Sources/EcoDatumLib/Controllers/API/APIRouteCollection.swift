import AuthProvider
import Vapor

final class APIRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  init(_ drop: Droplet) {
    self.drop = drop
  }
  
  func build(_ builder: RouteBuilder) throws {
    
    let api = builder.grouped("api")
    try V1RouteCollection(drop).build(api)
  
  }
  
}

