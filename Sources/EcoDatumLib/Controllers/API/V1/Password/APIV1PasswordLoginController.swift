import Vapor
import HTTP

final class APIV1PasswordLoginController: ResourceRepresentable {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  // POST /login
  func store(_ request: Request) throws -> ResponseRepresentable {
    
    let user = try request.user()
    drop.log.debug("Logging in as user: \(user.name)")
    return try modelManager.generateToken(for: user)
  
  }
  
  func makeResource() -> Resource<String> {
    return Resource(store: store)
  }
  
}


