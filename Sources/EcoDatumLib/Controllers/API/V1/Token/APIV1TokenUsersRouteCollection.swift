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
      User.parameter,
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

    let user = try request.parameters.next(User.self)
    try modelManager.assertRootOrRequestUser(user.id!.int!, request.user())
    return user
    
  }

  private func createNewUser(_ request: Request) throws -> ResponseRepresentable {
    
    try modelManager.assertRootUser(request.user())
    return try modelManager.createUser(json: try request.assertJson())
    
  }
  
}
