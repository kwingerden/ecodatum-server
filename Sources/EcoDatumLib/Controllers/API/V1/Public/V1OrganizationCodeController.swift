import Crypto
import Vapor

final class V1OrganizationCodeController: ResourceRepresentable {
  
  let drop: Droplet
  
  init(_ drop: Droplet) {
    self.drop = drop
  }
  
  // GET /organization/:code
  func show(_ request: Request,
            _ code: String) throws -> ResponseRepresentable {
    
    guard let organization = try Organization.makeQuery()
      .filter(Organization.Keys.code, .equals, code)
      .first() else {
      throw Abort(.notFound)
    }
    
    return organization
    
  }
  
  func makeResource() -> Resource<String> {
    return Resource(show: show)
  }
  
}



