import Vapor
import HTTP

final class MeController: ResourceRepresentable {
  
  // GET /me
  func index(_ request: Request) throws -> ResponseRepresentable {
    let user = try request.user()
    return "Hello, \(user.name)"
  }
  
  func makeResource() -> Resource<String> {
    return Resource(index: index)
  }
  
}


