import Crypto
import Vapor

final class OrganizationsController: ResourceRepresentable {
  
  let drop: Droplet
  
  init(_ drop: Droplet) {
    self.drop = drop
  }
  
  // POST /organizations
  func store(_ request: Request) throws -> ResponseRepresentable {
    
    guard let json = request.json else {
      throw Abort(.badRequest, reason: "Invalid type. Expecting JSON.")
    }
    
    guard let name = json["name"]?.string else {
      throw Abort(.badRequest, reason: "Organization must have a name.")
    }
    
    let code = String(randomUpperCaseAlphaNumericLength: 6)
    let result = try Organization.makeQuery().filter("code", code).first()
    guard result == nil else {
      throw Abort(.badRequest, reason: "An organization with code \(code) already exists.")
    }
    
    let userId = try request.user().assertExists()
    let organization = Organization(name: name, code: code,userId: userId)
    try organization.save()
    
    return organization
    
  }
  
  func makeResource() -> Resource<String> {
    return Resource(store: store)
  }
  
}

