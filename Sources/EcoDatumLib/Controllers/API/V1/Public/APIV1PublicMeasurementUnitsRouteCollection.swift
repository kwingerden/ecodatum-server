import HTTP
import Fluent
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
    
    // GET /measurementUnits
    routeBuilder.get(handler: getAllMeasurementUnits)
    
  }
  
  private func getAllMeasurementUnits(_ request: Request) throws -> ResponseRepresentable {
    return try MeasurementUnit.makeQuery().all().makeJSON()
  }
  
}

