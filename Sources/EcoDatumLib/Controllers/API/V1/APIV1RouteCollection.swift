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
  
  func build(_ rb: RouteBuilder) throws {
    
    let v1 = rb.grouped("v1")
    
    makePublicRoutes(v1)
    
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
      builder.get("organizations", Organization.parameter, "sites") {
        request in
        let organization = try request.parameters.next(Organization.self)
        return try organization.sites.all().makeJSON()
      }
      builder.resource(
        "sites",
        APIV1TokenSitesController(drop: drop, modelManager: modelManager))
      builder.resource(
        "users", 
        APIV1TokenUsersController(drop: drop, modelManager: modelManager))
    }
  }
  
  private func makePublicRoutes(_ routeBuilder: RouteBuilder) {
    
    let `public` = routeBuilder.grouped("public")
  
    APIV1PublicImagesRoutes(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("images"))
    
    APIV1PublicOrganizationsRoutes(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("organizations"))
    
    APIV1PublicUsersRoutes(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("users"))
    
  }
  
  
}

