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
      builder.resource(Constants.HELLO_RESOURCE, HelloController(drop))
      builder.resource(Constants.USERS_RESOURCE, UsersController(drop))
    }
    
    // MARK: Password Protected Contollers
    
    builder.group(middleware: [
      PasswordAuthenticationMiddleware(User.self)
    ]) {
      builder in
      builder.resource(Constants.LOGIN_RESOURCE, LoginController(drop))
    }
    
    // MARK: Token Protected Contollers
    
    builder.group(middleware: [
      TokenAuthenticationMiddleware(User.self)
    ]) {
      builder in
      builder.resource(Constants.ME_RESOURCE, MeController(drop))
      builder.resource(Constants.ORGANIZATIONS_RESOURCE, OrganizationsController(drop))
    }
  }
  
}
