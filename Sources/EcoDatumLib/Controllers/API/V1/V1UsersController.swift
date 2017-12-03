import Vapor
import HTTP

final class V1UsersController: ResourceRepresentable {
  
  let drop: Droplet
  
  init(_ drop: Droplet) {
    self.drop = drop
  }
  
  // POST /users
  func store(_ request: Request) throws -> ResponseRepresentable {
    
    guard let json = request.json else {
      throw Abort(.badRequest)
    }
    
    guard let email: String = try json.get(User.Keys.email) else {
      throw Abort(.badRequest, reason: "Organization must have a email.")
    }
    
    guard try User.makeQuery().filter(User.Keys.email, email).first() == nil else {
      throw Abort(.badRequest, reason: "A user with that email already exists.")
    }
    
    guard let name: String = try json.get(User.Keys.name) else {
      throw Abort(.badRequest, reason: "Organization must have a name.")
    }
    
    guard let password: String = try json.get(User.Keys.password) else {
      throw Abort(.badRequest, reason: "Organization must have a password.")
    }
    
    let user = User(
      name: name,
      email: email,
      password: try drop.hash.make(password.makeBytes()).makeString())
    try user.save()
    
    return user
    
  }
  
  func makeResource() -> Resource<String> {
    return Resource(store: store)
  }
  
}



