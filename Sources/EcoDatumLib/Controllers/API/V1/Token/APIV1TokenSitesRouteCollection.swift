import Vapor

final class APIV1TokenSitesRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    // GET /sites
    routeBuilder.get(
      handler: getSitesByUser)
    
    // GET /sites/:id
    routeBuilder.get(
      Site.parameter,
      handler: getSite)
    
    // POST /sites
    routeBuilder.post(
      handler: newSite)
    
    // PUT /sites/:id
    routeBuilder.put(
      Site.parameter,
      handler: updateSite)
    
    // DELETE /sites/:id
    routeBuilder.delete(
      Site.parameter,
      handler: deleteSite)
    
  }
  
  private func getSitesByUser(_ request: Request) throws -> ResponseRepresentable {
    
    if try modelManager.isRootUser(request.user()) {

      return try modelManager.getAllSites()
        .makeJSON()

    } else {

      return try modelManager.findSites(
        byUser: request.user())
        .makeJSON()

    }
    
  }
  
  private func getSite(_ request: Request) throws -> ResponseRepresentable {

    let (site, isRootUser, doesUserBelongToOrganization) =
      try isRootOrSiteUser(request)

    if isRootUser || doesUserBelongToOrganization {

      return site

    } else {

      throw Abort(.notFound)

    }
    
  }
  
  private func newSite(_ request: Request) throws -> ResponseRepresentable {
    
    let json = try request.assertJson()
    
    guard let organizationId: Identifier = try json.get(Site.Json.organizationId),
      let organization = try modelManager.findOrganization(byId: organizationId) else {
        throw Abort(.badRequest, reason: "Site must have associated organization.")
    }
    
    let (isRootUser, doesUserBelongToOrganization) =
      try isRootOrOrganizationUser(request, organization)
    
    guard isRootUser || doesUserBelongToOrganization else {
      throw Abort(.notFound)
    }
    
    let (name, description, latitude, longitude) = try toSiteAttributes(json)
    
    if let site = try modelManager.findSite(byName: name) {
      throw Abort(.conflict, reason: "Site \(site.name) already exists.")
    }
    
    return try modelManager.createSite(
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      user: try request.user(),
      organization: organization)

  }

  private func updateSite(_ request: Request) throws -> ResponseRepresentable {
    
    let (site, isRootUser, doesUserBelongToOrganization) =
      try isRootOrSiteUser(request)
    
    if isRootUser || doesUserBelongToOrganization {
      
      let json = try request.assertJson()
      
      let (name, description, latitude, longitude) = try toSiteAttributes(json)
      
      if let findSite = try modelManager.findSite(byName: name),
         findSite.id != site.id {
        throw Abort(.conflict, reason: "Site \(site.name) already exists.")
      }
      
      site.name = name
      site.description = description
      site.latitude = latitude
      site.longitude = longitude
      
      return try modelManager.updateSite(site: site)
      
    } else {
      
      throw Abort(.notFound)
      
    }
    
  }
  
  private func deleteSite(_ request: Request) throws -> ResponseRepresentable {
    
    let (site, isRootUser, doesUserBelongToOrganization) =
      try isRootOrSiteUser(request)
    
    if isRootUser || doesUserBelongToOrganization {
      
      try modelManager.transaction {
        connection in
        try self.modelManager.deleteSite(connection, site: site)
      }
      
      return Response(status: .ok)
      
    } else {
      
      throw Abort(.notFound)
      
    }
    
  }
  
  private func toSiteAttributes(_ json: JSON) throws ->
    (name: String, description: String?, latitude: Double, longitude: Double) {
    
    guard let name: String = try json.get(Site.Json.name),
      !name.isEmpty else {
        throw Abort(.badRequest, reason: "Site must have a name.")
    }
    
    var description: String? = nil
    if let _description: String = try json.get(Site.Json.description),
      !_description.isEmpty {
      description = _description
    }
    
    guard let latitude: Double = try json.get(Site.Json.latitude) else {
      throw Abort(.badRequest, reason: "Site must have a latitude.")
    }
    
    guard let longitude: Double = try json.get(Site.Json.longitude) else {
      throw Abort(.badRequest, reason: "Site must have a longitude.")
    }
    
    return (name: name, description: description, latitude: latitude, longitude: longitude)
      
  }
  
  private func isRootOrOrganizationUser(
    _ request: Request,
    _ organization: Organization)
    throws -> (Bool, Bool) {
    
    let user = try request.user()
    let isRootUser = try modelManager.isRootUser(user)
    let doesUserBelongToOrganization = try modelManager.doesUserBelongToOrganization(
      user: user,
      organization: organization)
    
    return (isRootUser, doesUserBelongToOrganization)
    
  }
  
  private func isRootOrSiteUser(_ request: Request) throws -> (Site, Bool, Bool) {

    let site = try request.parameters.next(Site.self)
    guard let organization = try site.organization.get() else {
      throw Abort(.internalServerError)
    }
    
    let (isRootUser, doesUserBelongToOrganization) =
      try isRootOrOrganizationUser(request, organization)

    return (site, isRootUser, doesUserBelongToOrganization)

  }
  
}
