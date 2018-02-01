import HTTP
import Vapor

final class APIV1TokenUsersRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    // GET /users
    routeBuilder.get(
      handler: getAllUsers)
    
    // GET /users/:id
    routeBuilder.get(
      Int.parameter,
      handler: getUserById)
    
    // POST /users
    routeBuilder.post(
      handler: createNewUser)
    
  }
  
  private func getAllUsers(_ request: Request) throws -> ResponseRepresentable {
    
    try modelManager.assertRootUser(request.user())
    return try modelManager.getAllUsers().makeJSON()
  
  }
  
  private func getUserById(_ request: Request) throws -> ResponseRepresentable {
    
    guard let id = try? request.parameters.next(Int.self) else {
        throw Abort(.notFound)
    }
    
    try modelManager.assertRootOrRequestUser(id, request.user())
    return try modelManager.getUser(byId: Identifier(id))
    
  }

  private func createNewUser(_ request: Request) throws -> ResponseRepresentable {
    
    try modelManager.assertRootUser(request.user())
    return try modelManager.createUser(json: try request.assertJson())
    
  }
  
}
