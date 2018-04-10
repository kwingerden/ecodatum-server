import Crypto
import Vapor

final class APIV1PublicQualitativeObservationTypesRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    routeBuilder.get(handler: getQualitativeObservationTypesRouteHandler)
    
  }
  
  // GET /public/qualitativeObservationTypes
  private func getQualitativeObservationTypesRouteHandler(_ request: Request) throws -> ResponseRepresentable {

    return try QualitativeObservationType.all().makeJSON()
      
  }

}



