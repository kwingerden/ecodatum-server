import Crypto
import Vapor

final class APIV1PublicQuantitativeObservationTypesRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    routeBuilder.get(handler: getQuantitativeObservationTypesRouteHandler)
    
  }
  
  // GET /public/quantitativeObservationTypes
  private func getQuantitativeObservationTypesRouteHandler(_ request: Request) throws -> ResponseRepresentable {

    return try QuantitativeObservationType.all().makeJSON()
      
  }

}



