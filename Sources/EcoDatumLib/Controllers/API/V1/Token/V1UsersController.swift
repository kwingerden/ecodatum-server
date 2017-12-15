import Vapor
import HTTP

final class V1UsersController: ResourceRepresentable {
  
  let drop: Droplet
  
  init(_ drop: Droplet) {
    self.drop = drop
  }
  
  // GET /users
  func index(_ request: Request) throws -> ResponseRepresentable {
    
    guard try request.user().isAdmin else {
        throw Abort(.unauthorized)
    }
    return try User.all().makeJSON()
  
  }
  
  // GET /users/:id
  func show(_ request: Request,
            _ user: User) throws -> ResponseRepresentable {
    
    guard try request.user().isAdmin else {
      throw Abort(.unauthorized)
    }
    return user
    
  }

  // POST /users
  func store(_ request: Request) throws -> ResponseRepresentable {
    
    guard let json = request.json else {
      throw Abort(.badRequest)
    }
    
    let user = try User(json: json)
    user.password = try drop.hash.make(user.password.makeBytes()).makeString()
    try user.save()
    
    return user
    
  }
  
  func makeResource() -> Resource<User> {
    return Resource(index: index,
                    store: store,
                    show: show)
  }
  
}



