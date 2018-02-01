import HTTP
import Vapor

final class APIV1TokenMeasurementsRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    // GET /measurements
    routeBuilder.get(
      handler: getAllMeasurements)
    
  }
  
  private func getAllMeasurements(_ request: Request) throws -> ResponseRepresentable {
    
    try modelManager.assertRootUser(request.user())
    return try modelManager.getAllUsers().makeJSON()
    
  }
  
}

