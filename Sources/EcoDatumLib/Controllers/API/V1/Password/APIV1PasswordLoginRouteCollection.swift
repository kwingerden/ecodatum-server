import Vapor
import HTTP

final class APIV1PasswordLoginRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    routeBuilder.post(handler: login)
  
  }
  
  // POST /login
  func login(_ request: Request) throws -> ResponseRepresentable {
    
    let user = try request.user()
    drop.log.debug("Logging in as user: \(user.fullName)")
    
    return try modelManager.generateToken(for: user)
  
  }
  
}


