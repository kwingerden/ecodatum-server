import HTTP
import Vapor

final class APIV1TokenUsersController: ResourceRepresentable {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  // GET /users
  func index(_ request: Request) throws -> ResponseRepresentable {
    
    try modelManager.assertRootUser(request.user())
    return try modelManager.getAllUsers().makeJSON()
  
  }
  
  // GET /users/:id
  func show(_ request: Request,
            _ userId: Int) throws -> ResponseRepresentable {
    
    try modelManager.assertRootOrRequestUser(userId, request.user())
    return try modelManager.getUser(byId: Identifier(userId))
    
  }

  // POST /users
  func store(_ request: Request) throws -> ResponseRepresentable {
    
    try modelManager.assertRootUser(request.user())
    return try modelManager.createUser(json: try request.assertJson())
    
  }
  
  func makeResource() -> Resource<Int> {
    return Resource(index: index,
                    store: store,
                    show: show)
  }
  
}
