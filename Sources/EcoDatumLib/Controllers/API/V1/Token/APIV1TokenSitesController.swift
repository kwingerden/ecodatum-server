import Vapor

final class APIV1TokenSitesController: ResourceRepresentable {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  // GET /sites
  func index(_ request: Request) throws -> ResponseRepresentable {
    
    if try modelManager.isRootUser(request.user()) {
      return try modelManager.getAllSites().makeJSON()
    } else {
      return try modelManager.findSites(byUser: request.user()).makeJSON()
    }
    
  }
  
  // GET /sites/:id
  func show(_ request: Request,
            _ site: Site) throws -> ResponseRepresentable {
    
    if try modelManager.isRootUser(request.user()) {
      return site
    } else if let organization = try site.organization.get(),
      try modelManager.doesUserBelongToOrganization(
        user: request.user(),
        organization: organization) {
      return site
    } else {
      throw Abort(.notFound)
    }
    
  }
  
  // POST /sites
  func store(_ request: Request) throws -> ResponseRepresentable {
    
    guard let json = try? request.assertJson() else {
      throw Abort(.badRequest, reason: "Expecting JSON.")
    }
    
    guard let name: String = try? json.get(Site.Json.name),
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
    
    guard let organizationId: Identifier = try json.get(Site.Json.organizationId),
      let organization = try modelManager.findOrganization(byId: organizationId) else {
      throw Abort(.badRequest, reason: "Site must have associated organization.")
    }
    
    return try modelManager.createSite(
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      user: try request.user(),
      organization: organization)

  }
  
  func makeResource() -> Resource<Site> {
    return Resource(
      index: index,
      store: store,
      show: show)
  }
  
}