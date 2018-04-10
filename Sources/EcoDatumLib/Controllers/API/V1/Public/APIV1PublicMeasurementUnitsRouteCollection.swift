import Crypto
import Vapor

final class APIV1PublicMeasurementUnitsRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    routeBuilder.get(handler: getMeasurementUnitsRouteHandler)
    
  }
  
  // GET /public/measurementUnit
  private func getMeasurementUnitsRouteHandler(_ request: Request) throws -> ResponseRepresentable {

    return try MeasurementUnit.all().makeJSON()
      
  }

}



