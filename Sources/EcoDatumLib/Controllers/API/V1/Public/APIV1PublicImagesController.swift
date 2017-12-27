import Crypto
import Vapor

final class APIV1PublicImagesController: ResourceRepresentable {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  // GET public/images/:hash
  func show(_ request: Request,
            _ code: String) throws -> ResponseRepresentable {
    
    guard let organization = try modelManager.findOrganization(byCode: code) else {
      throw Abort(.notFound)
    }
    
    return organization
    
  }
  
  func makeResource() -> Resource<String> {
    return Resource(show: show)
  }
  
}




