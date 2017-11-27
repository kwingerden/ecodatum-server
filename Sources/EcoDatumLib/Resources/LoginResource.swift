import Vapor
import HTTP

final class LoginController: ResourceRepresentable {
    
  // POST /login
  func store(_ request: Request) throws -> ResponseRepresentable {
    let user = try request.user()
    let token = try Token.generate(for: user)
    try token.save()
    return token
  }
  
  func makeResource() -> Resource<String> {
    return Resource(store: store)
  }
  
}

