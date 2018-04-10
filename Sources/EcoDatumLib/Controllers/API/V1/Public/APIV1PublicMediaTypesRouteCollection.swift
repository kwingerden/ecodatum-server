import Crypto
import Vapor

final class APIV1PublicMediaTypesRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    routeBuilder.get(handler: getMediaTypesRouteHandler)
    
  }
  
  // GET /public/mediaTypes
  private func getMediaTypesRouteHandler(_ request: Request) throws -> ResponseRepresentable {

    return try MediaType.all().makeJSON()
      
  }

}



