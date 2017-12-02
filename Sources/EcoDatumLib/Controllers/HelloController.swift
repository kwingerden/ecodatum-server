import Vapor
import HTTP

final class HelloController: ResourceRepresentable {
  
  let drop: Droplet
  
  init(_ drop: Droplet) {
    self.drop = drop
  }
  
  // GET /hello
  func index(_ request: Request) throws -> ResponseRepresentable {
    return try drop.view.make("hello", [
      "name": "World"
      ], for: request)
  }
  
  // GET /hello/:string
  func show(_ request: Request, _ string: String) throws -> ResponseRepresentable {
    return try drop.view.make("hello", [
      "name": string
      ], for: request)
  }
  
  func makeResource() -> Resource<String> {
    return Resource(
      index: index,
      show: show
    )
  }
  
}
