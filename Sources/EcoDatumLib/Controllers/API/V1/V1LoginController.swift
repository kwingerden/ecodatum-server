import Vapor
import HTTP

final class V1LoginController: ResourceRepresentable {
  
  let drop: Droplet
  
  init(_ drop: Droplet) {
    self.drop = drop
  }
  
  // POST /login
  func store(_ request: Request) throws -> ResponseRepresentable {
    let user = try request.user()
    drop.log.debug("Logging in as user: \(user.name)")
    let token = try Token.generate(for: user)
    try token.save()
    return token
  }
  
  func makeResource() -> Resource<String> {
    return Resource(store: store)
  }
  
}


