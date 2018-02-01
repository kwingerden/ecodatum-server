import Crypto
import Vapor

final class APIV1TokenOrganizationsRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {

    // GET /organizations
    routeBuilder.get(
      handler: getOrganizationsByUser)
    
    // GET /organizations/:id/sites
    routeBuilder.get(
      Organization.parameter, "sites",
      handler: getSitesByOrganization)
    
    // POST /organizations
    routeBuilder.post(
      handler: createNewOrganization)
    
    // DELETE /organizations
    routeBuilder.delete(
      handler: deleteAllOrganizations)
    
    // DELETE /organizations/:id
    routeBuilder.delete(
      Int.parameter,
      handler: deleteOrganizationById)
    
  }
  
  private func getOrganizationsByUser(_ request: Request) throws -> ResponseRepresentable {
    
    if try modelManager.isRootUser(request.user()) {
      return try modelManager.getAllOrganizations().makeJSON()
    } else {
      return try modelManager.findOrganizations(
        byUser: request.user())
        .makeJSON()
    }
    
  }
  
  private func getSitesByOrganization(_ request: Request) throws -> ResponseRepresentable {
    
    let organization = try request.parameters.next(Organization.self)
    return try organization.sites.all().makeJSON()
    
  }
  
  private func getOrganizationById(_ request: Request) throws -> ResponseRepresentable {
    
    guard let id = try? request.parameters.next(Int.self),
      let organization = try modelManager.findOrganization(byId: Identifier(id)) else {
        throw Abort(.notFound)
    }
    
    if try modelManager.isRootUser(request.user()) {
      return organization
    } else if try modelManager.doesUserBelongToOrganization(
      user: request.user(),
      organization: organization) {
      return organization
    } else {
      throw Abort(.notFound)
    }
    
  }
  
  private func createNewOrganization(_ request: Request) throws -> ResponseRepresentable {
    
    guard let json = try? request.assertJson() else {
      throw Abort(.badRequest, reason: "Expecting JSON.")
    }
    
    guard let name: String = try? json.get(Organization.Keys.name) else {
      throw Abort(.badRequest, reason: "Organization must have a name.")
    }
    
    var description: String? = nil
    if let _description: String = try json.get(Organization.Keys.description),
      !_description.isEmpty {
      description = _description
    }
    
    return try modelManager.createOrganization(
      user: try request.user(),
      name: name,
      description: description)

  }
  
  private func deleteOrganizationById(_ request: Request) throws -> ResponseRepresentable {
    
    guard let id = try? request.parameters.next(Int.self),
      let organization = try modelManager.findOrganization(byId: Identifier(id)) else {
        throw Abort(.notFound)
    }
    
    if try modelManager.isRootUser(request.user()) {
      try modelManager.deleteOrganization(organization: organization)
      return Response(status: .ok)
    } else if try modelManager.doesUserBelongToOrganization(
      user: request.user(),
      organization: organization) {
      try modelManager.deleteOrganization(organization: organization)
      return Response(status: .ok)
    } else {
      throw Abort(.notFound)
    }
    
  }
  
  private func deleteAllOrganizations(_ request: Request) throws -> ResponseRepresentable {
    
    try modelManager.assertRootUser(request.user())
    try modelManager.deleteAllOrganizations()
    
    return Response(status: .ok)
    
  }
  
}


