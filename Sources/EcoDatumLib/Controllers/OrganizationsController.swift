import Crypto
import Vapor

final class OrganizationsController: ResourceRepresentable {
  
  // POST /organizations
  func store(_ request: Request) throws -> ResponseRepresentable {
    
    guard let json = request.json else {
      throw Abort(.badRequest, reason: "Invalid type. Expecting JSON.")
    }
    
    guard let name = json["name"]?.string else {
      throw Abort(.badRequest, reason: "Organization must have a name.")
    }
    
    let code = String(
      randomWithLength: 6,
      allowedCharactersType: .alphaNumeric)
      .uppercased()
    guard try Organization.makeQuery().filter("code", code).first() == nil else {
      throw Abort(.badRequest, reason: "An organization with that code already exists.")
    }
    
    let userId = try request.user().assertExists()
    let organization = Organization(
      name: name,
      code: code,
      userId: userId)
    
    try organization.save()
    
    return organization
    
  }
  
  
  func makeResource() -> Resource<String> {
    return Resource(store: store)
  }
  
}

