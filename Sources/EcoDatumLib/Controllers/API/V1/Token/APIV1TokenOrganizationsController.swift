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
    
    try modelManager.assertRootUser(request.user())
    return try modelManager.getAllOrganizations().makeJSON()
    
  }
  
  // GET /organizations/:id
  func show(_ request: Request,
            _ organization: Organization) throws -> ResponseRepresentable {
    
    //try assertUserOwnsOrganizationOrIsAdmin(request, organization)
    return organization
    
  }
  
  // POST /organizations
  func store(_ request: Request) throws -> ResponseRepresentable {
    
    guard let name: String = try request.assertJson().get(Organization.Keys.name) else {
      throw Abort(.badRequest, reason: "Organization must have a name.")
    }
    
    //let userId = try request.user().assertExists()
    let organization = Organization(name: name,
                                    code: String(randomUpperCaseAlphaNumericLength: 6))
    try organization.save()
    
    return organization
    
  }
  
  // PATCH /organizations/:id
  func update(_ request: Request,
              organization: Organization) throws -> ResponseRepresentable {
    
    //try assertUserOwnsOrganizationOrIsAdmin(request, organization)
    //try organization.update(for: request)
    try organization.save()
    
    return organization
    
  }
  
  // DELETE /organizations/:id
  func destroy(_ request: Request,
               organization: Organization) throws -> ResponseRepresentable {
    
    //try assertUserOwnsOrganizationOrIsAdmin(request, organization)
    try organization.delete()
    
    return Response(status: .ok)
    
  }
  
  // DELETE /organizations
  func clear(_ request: Request) throws -> ResponseRepresentable {
    
    //try request.assertRootUser()
    try Organization.makeQuery().delete()
    
    return Response(status: .ok)
    
  }
  
  func makeResource() -> Resource<Organization> {
    return Resource(
      index: index,
      store: store,
      show: show,
      update: update,
      destroy: destroy,
      clear: clear)
  }
  
}


