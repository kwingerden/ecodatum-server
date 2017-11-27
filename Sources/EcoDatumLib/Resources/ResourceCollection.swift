import AuthProvider
import Vapor

final class Controllers: RouteCollection {
  
  let hash: HashProtocol
  
  let view: ViewRenderer
  
  init(_ hash: HashProtocol,
       _ view: ViewRenderer) {
    self.hash = hash
    self.view = view
  }
  
  func build(_ builder: RouteBuilder) throws {
  
    builder.group(middleware: []) {
      builder in
      builder.resource("hello", HelloController(view))
      builder.resource("users", UsersResource(hash))
    }
    
    builder.group(middleware: [
      PasswordAuthenticationMiddleware(User.self)
    ]) {
      builder in
      builder.resource("login", LoginController())
    }
    
    builder.group(middleware: [
      TokenAuthenticationMiddleware(User.self)
    ]) {
      builder in
      builder.resource("me", MeResource())
    }
  }
  
}
