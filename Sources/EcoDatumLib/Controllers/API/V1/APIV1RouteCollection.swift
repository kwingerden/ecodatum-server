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

    // /public/ecosystemFactors
    APIV1PublicEcosystemFactorsRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("ecosystemFactors"))

    // /public/measurementUnits
    APIV1PublicMeasurementUnitsRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("measurementUnits"))

    // /public/mediaTypes
    APIV1PublicMediaTypesRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("mediaTypes"))

    // /public/organizations
    APIV1PublicOrganizationsRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("organizations"))

    // /public/qualitativeObservationTypes
    APIV1PublicQualitativeObservationTypesRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("qualitativeObservationTypes"))

    // /public/quantitativeObservationTypes
    APIV1PublicQuantitativeObservationTypesRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(`public`.grouped("quantitativeObservationTypes"))

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
    
    let expirationSeconds = drop.config["app", "token-expiration-seconds"]?.int ?? 86400
    let tokenProtected = routeBuilder.grouped("protected").grouped([
      TokenExpirationMiddleware(expirationSeconds),
      TokenAuthenticationMiddleware(User.self)])
    
    // /protected/logout
    APIV1TokenLogoutRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(tokenProtected.grouped("logout"))
    
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

    // /protected/ecodatum
    APIV1TokenEcoDatumRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(tokenProtected.grouped("ecodatum"))

    // /protected/users
    APIV1TokenUsersRouteCollection(
      drop: drop,
      modelManager: modelManager)
      .build(tokenProtected.grouped("users"))
  
  }

}

