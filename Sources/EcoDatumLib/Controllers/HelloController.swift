import Vapor
import HTTP

final class HelloController: ResourceRepresentable {
  
  let view: ViewRenderer
  
  init(_ view: ViewRenderer) {
    self.view = view
  }
  
  // GET /hello
  func index(_ req: Request) throws -> ResponseRepresentable {
    return try view.make("hello", [
      "name": "World"
      ], for: req)
  }
  
  // GET /hello/:string
  func show(_ req: Request, _ string: String) throws -> ResponseRepresentable {
    return try view.make("hello", [
      "name": string
      ], for: req)
  }
  
  func makeResource() -> Resource<String> {
    return Resource(
      index: index,
      show: show
    )
  }
  
}
