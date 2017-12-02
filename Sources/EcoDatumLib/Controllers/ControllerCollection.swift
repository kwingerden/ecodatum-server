import AuthProvider
import Vapor

final class ControllerCollection: RouteCollection {
  
  let drop: Droplet
  
  init(_ drop: Droplet) {
    self.drop = drop
  }
  
  func build(_ builder: RouteBuilder) throws {
  
    // MARK: Unauthenticated Contollers
    
    builder.group(middleware: []) {
      builder in
      builder.resource("hello", HelloController(drop))
      builder.resource("users", UsersController(drop))
    }
    
    // MARK: Password Protected Contollers
    
    builder.group(middleware: [
      PasswordAuthenticationMiddleware(User.self)
    ]) {
      builder in
      builder.resource("login", LoginController(drop))
    }
    
    // MARK: Token Protected Contollers
    
    builder.group(middleware: [
      TokenAuthenticationMiddleware(User.self)
    ]) {
      builder in
      builder.resource("me", MeController(drop))
      builder.resource("organizations", OrganizationsController(drop))
    }
  }
  
}
