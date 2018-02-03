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
    makePasswordProtectedRoutes(v1)
    makeTokenProtectedRoutes(v1)
    
  }
  
  private func makePublicRoutes(_ routeBuilder: RouteBuilder) {
    
    let `public` = routeBuilder.grouped("public")
  
    // /public/abioticFactors
    APIV1PublicAbioticFactorsRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("abioticFactors"))
    
    // /public/images
    APIV1PublicImagesRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("images"))
    
    // /public/measurementUnits
    APIV1PublicMeasurementUnitsRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("measurementUnits"))
    
    // /public/organizations
    APIV1PublicOrganizationsRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("organizations"))
    
    // /public/users
    APIV1PublicUsersRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("users"))
    
  }
  
  private func makePasswordProtectedRoutes(_ routeBuilder: RouteBuilder) {
    
    let passwordProtected = routeBuilder.grouped(
      [PasswordAuthenticationMiddleware(User.self)])
    
    // /login
    APIV1PasswordLoginRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(passwordProtected.grouped("login"))
    
  }
  
  private func makeTokenProtectedRoutes(_ routeBuilder: RouteBuilder) {
    
    let exirationSeconds = drop.config["app", "token-expiration-seconds"]?.int ?? 86400
    let tokenProtected = routeBuilder.grouped("protected").grouped([
      TokenExpirationMiddleware(exirationSeconds),
      TokenAuthenticationMiddleware(User.self)])
    
    // /protected/logout
    APIV1TokenLogoutRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(tokenProtected.grouped("logout"))
    
    // /protected/measurements
    APIV1TokenMeasurementsRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(tokenProtected.grouped("measurements"))
    
    // /protected/organizations
    APIV1TokenOrganizationsRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(tokenProtected.grouped("organizations"))
    
    // /protected/sites
    APIV1TokenSitesRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(tokenProtected.grouped("sites"))
    
    // /protected/surveys
    APIV1TokenSurveysRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(tokenProtected.grouped("surveys"))
    
    // /protected/users
    APIV1TokenUsersRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(tokenProtected.grouped("users"))
  
  }

}

