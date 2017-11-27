import Vapor
import HTTP

final class HelloController: ResourceRepresentable {
  
  let view: ViewRenderer
  
  init(_ view: ViewRenderer) {
    self.view = view
  }
  
  // GET /hello
  func index(_ request: Request) throws -> ResponseRepresentable {
    return try view.make("hello", [
      "name": "World"
      ], for: request)
  }
  
  // GET /hello/:string
  func show(_ request: Request, _ string: String) throws -> ResponseRepresentable {
    return try view.make("hello", [
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
