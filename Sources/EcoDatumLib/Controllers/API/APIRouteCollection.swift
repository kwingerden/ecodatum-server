import AuthProvider
import Vapor

final class APIRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(_ drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ builder: RouteBuilder) throws {
    
    let api = builder.grouped("api")
    try APIV1RouteCollection(drop: drop, modelManager: modelManager).build(api)
  
  }
  
}

