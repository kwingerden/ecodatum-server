import AuthProvider
import Vapor

final class APIV1RouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ builder: RouteBuilder) throws {
    
    let v1 = builder.grouped("v1")
    
    // MARK: Public Controllers
    
    let `public` = v1.grouped("public")
    `public`.group(middleware: []) {
      builder in
      builder.resource(
        "images",
        APIV1PublicImagesController(drop: drop, modelManager: modelManager))
      builder.resource(
        "organizations", 
        APIV1PublicOrganizationsController(drop: drop, modelManager: modelManager))
    }
    
    // MARK: Password Protected Contollers
    
    v1.group(middleware: [
      PasswordAuthenticationMiddleware(User.self)
    ]) {
      builder in
      builder.resource(
        "login", 
        APIV1PasswordLoginController(drop: drop, modelManager: modelManager))
    }
    
    // MARK: Token Protected Contollers
    
    let protected = v1.grouped("protected")
    let exirationSeconds = drop.config["app", "token-expiration-seconds"]?.int ?? 86400
    protected.group(middleware: [
      TokenExpirationMiddleware(exirationSeconds),
      TokenAuthenticationMiddleware(User.self)
    ]) {
      builder in
      builder.resource(
        "logout", 
        APIV1TokenLogoutController(drop: drop, modelManager: modelManager))
      builder.resource(
        "me", 
        APIV1TokenMeController(drop: drop, modelManager: modelManager))
      builder.resource(
        "images", 
        APIV1TokenImagesController(drop: drop, modelManager: modelManager))
      builder.resource(
        "organizations", 
        APIV1TokenOrganizationsController(drop: drop, modelManager: modelManager))
      builder.resource(
        "users", 
        APIV1TokenUsersController(drop: drop, modelManager: modelManager))
    }
  }
  
}

