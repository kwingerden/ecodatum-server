import Crypto
import Vapor

final class APIV1TokenOrganizationsController: ResourceRepresentable {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  // GET /organizations
  func index(_ request: Request) throws -> ResponseRepresentable {
    
    if try modelManager.isRootUser(request.user()) {
      return try modelManager.getAllOrganizations().makeJSON()
    } else {
      return try modelManager.findOrganizations(
        byUser: request.user())
        .makeJSON()
    }
    
  }
  
  // GET /organizations/:id
  func show(_ request: Request,
            _ organization: Organization) throws -> ResponseRepresentable {
    
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
  
  // POST /organizations
  func store(_ request: Request) throws -> ResponseRepresentable {
    
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
  
  // DELETE /organizations/:id
  func destroy(_ request: Request,
               organization: Organization) throws -> ResponseRepresentable {
    
    try modelManager.assertRootUser(request.user())
    try modelManager.deleteOrganization(organization: organization)
    
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
  
  // DELETE /organizations
  func clear(_ request: Request) throws -> ResponseRepresentable {
    
    try modelManager.assertRootUser(request.user())
    try modelManager.deleteAllOrganizations()
    
    return Response(status: .ok)
    
  }
  
  func makeResource() -> Resource<Organization> {
    return Resource(
      index: index,
      store: store,
      show: show,
      destroy: destroy,
      clear: clear)
  }
  
}


