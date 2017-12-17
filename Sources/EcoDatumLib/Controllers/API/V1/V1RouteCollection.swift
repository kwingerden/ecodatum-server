import AuthProvider
import Vapor

final class V1RouteCollection: RouteCollection {
  
  let drop: Droplet
  
  init(_ drop: Droplet) {
    self.drop = drop
  }
  
  func build(_ builder: RouteBuilder) throws {
    
    let v1 = builder.grouped("v1")
    
    // MARK: Public Controllers
    
    let `public` = builder.grouped("public")
    `public`.group(middleware: []) {
        builder in
        builder.resource("organization", V1OrganizationCodeController(drop))
    }
    
    // MARK: Password Protected Contollers
    
    v1.group(middleware: [
      PasswordAuthenticationMiddleware(User.self)]) {
      builder in
      builder.resource("login", V1LoginController(drop))
    }
    
    // MARK: Token Protected Contollers
    
    let exirationSeconds = drop.config["app", "token-expiration-seconds"]?.int ?? 86400
    v1.group(middleware: [
      TokenExpirationMiddleware(exirationSeconds),
      TokenAuthenticationMiddleware(User.self)]) {
      builder in
      builder.resource("logout", V1LogoutController(drop))
      builder.resource("me", V1MeController(drop))
      do {
        builder.resource("photos", try V1PhotosController(drop))
      } catch {
        drop.log.error("Failed to create V1PhotosController")
      }
      builder.resource("organizations", V1OrganizationsController(drop))
      builder.resource("users", V1UsersController(drop))
    }
  }
  
}

