import Vapor
import HTTP

final class APIV1TokenMeController: ResourceRepresentable {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  // GET /me
  func index(_ request: Request) throws -> ResponseRepresentable {
    let user = try request.user()
    return "Hello, \(user.name)"
  }
  
  func makeResource() -> Resource<String> {
    return Resource(index: index)
  }
  
}



