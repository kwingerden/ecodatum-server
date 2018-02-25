import Crypto
import Vapor

final class APIV1PublicOrganizationsRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    routeBuilder.get(
      String.parameter,
      handler: getOrganizationByCodeRouteHandler)
    
    routeBuilder.get(
      "roles",
      handler: getOrganizationRoles)
    
  }
  
  // GET /public/organizations/:code
  private func getOrganizationByCodeRouteHandler(
    _ request: Request)
    throws -> ResponseRepresentable {
      
      guard let code = try? request.parameters.next(String.self),
        let organization = try modelManager.findOrganization(byCode: code) else {
          throw Abort(.notFound)
      }
      
      return organization
      
  }
  
  // GET /public/organizations/roles
  private func getOrganizationRoles(
    _ request: Request)
    throws -> ResponseRepresentable {
      
      return try Role.all().makeJSON()
      
  }
  
}



