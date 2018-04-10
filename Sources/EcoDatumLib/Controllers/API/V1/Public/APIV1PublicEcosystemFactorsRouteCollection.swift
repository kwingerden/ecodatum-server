import Crypto
import Vapor

final class APIV1PublicEcosystemFactorsRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    routeBuilder.get(handler: getEcosystemFactorsRouteHandler)
    
  }
  
  // GET /public/ecosystemFactors
  private func getEcosystemFactorsRouteHandler(_ request: Request) throws -> ResponseRepresentable {

    return try EcosystemFactor.all().makeJSON()
      
  }

}



