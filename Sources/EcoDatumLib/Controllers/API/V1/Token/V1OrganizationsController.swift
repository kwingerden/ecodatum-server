import Crypto
import Vapor

final class V1OrganizationsController: ResourceRepresentable {
  
  let drop: Droplet
  
  init(_ drop: Droplet) {
    self.drop = drop
  }
  
  // GET /organizations
  func index(_ request: Request) throws -> ResponseRepresentable {
    
    guard try request.user().isAdmin else {
      throw Abort(.unauthorized)
    }
    return try Organization.all().makeJSON()
  
  }
  
  // GET /organizations/:id
  func show(_ request: Request,
            _ organization: Organization) throws -> ResponseRepresentable {
  
    guard try request.user().isAdmin else {
      throw Abort(.unauthorized)
    }
    return organization
  
  }
  
  // POST /organizations
  func store(_ request: Request) throws -> ResponseRepresentable {
    
    guard let json = request.json else {
      throw Abort(.badRequest, reason: "Invalid type. Expecting JSON.")
    }
    
    guard let name: String = try json.get(Organization.Keys.name) else {
      throw Abort(.badRequest, reason: "Organization must have a name.")
    }
    
    let code = String(randomUpperCaseAlphaNumericLength: 6)
    let result = try Organization.makeQuery().filter(Organization.Keys.code, code).first()
    guard result == nil else {
      throw Abort(.badRequest, reason: "An organization with code \(code) already exists.")
    }
    
    let userId = try request.user().assertExists()
    let organization = Organization(name: name, code: code, userId: userId)
    try organization.save()
    
    return organization
    
  }
  
  // PATCH /organizations/:id
  func update(_ request: Request,
              organization: Organization) throws -> ResponseRepresentable {
    try organization.update(for: request)
    try organization.save()
    return organization
  }
  
  // DELETE /organizations/:id
  func destroy(_ request: Request,
               organization: Organization) throws -> ResponseRepresentable {
    try organization.delete()
    return Response(status: .ok)
  }
  
  // DELETE /organizations
  func clear(_ request: Request) throws -> ResponseRepresentable {
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


