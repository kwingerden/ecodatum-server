import AuthProvider
import Vapor

final class ControllerCollection: RouteCollection {
  
  let hash: HashProtocol
  
  let view: ViewRenderer
  
  init(_ hash: HashProtocol,
       _ view: ViewRenderer) {
    self.hash = hash
    self.view = view
  }
  
  func build(_ builder: RouteBuilder) throws {
  
    // MARK: Unauthenticated Contollers
    
    builder.group(middleware: []) {
      builder in
      builder.resource("hello", HelloController(view))
      builder.resource("users", UsersController(hash))
    }
    
    // MARK: Password Protected Contollers
    
    builder.group(middleware: [
      PasswordAuthenticationMiddleware(User.self)
    ]) {
      builder in
      builder.resource("login", LoginController())
    }
    
    // MARK: Token Protected Contollers
    
    builder.group(middleware: [
      TokenAuthenticationMiddleware(User.self)
    ]) {
      builder in
      builder.resource("me", MeController())
      builder.resource("organizations", OrganizationsController())
    }
  }
  
}
