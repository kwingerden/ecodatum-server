import Vapor
import HTTP

final class APIV1PublicUsersController: ResourceRepresentable {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  // POST public/users?code=:code
  func store(_ request: Request) throws -> ResponseRepresentable {
    
    guard let organizationCode = request.query?["code"]?.string else {
      throw Abort(.badRequest, reason: "Must supply organization code query parameter.")
    }
    
    guard let _organization = try? modelManager.findOrganization(byCode: organizationCode),
      let organization = _organization else {
      throw Abort(.notFound, reason: "Unable to find organization with code: \(organizationCode)")
    }
    
    guard let json = request.json else {
      throw Abort(.badRequest, reason: "Invalid JSON")
    }
    
    guard let user = try? modelManager.createUser(json: json) else {
      throw Abort(.internalServerError, reason: "Failed to create user")
    }
    
    guard let role = try? modelManager.getRole(name: .MEMBER) else {
      throw Abort(.internalServerError, reason: "Failed to get Role")
    }
    
    guard let _ = try? modelManager.addUserToOrganization(
      user: user,
      organization: organization,
      role: role) else {
      throw Abort(.internalServerError, reason: "Failed to get Role")
    }
    
    return user
    
  }
  
  func makeResource() -> Resource<User> {
    return Resource(store: store)
  }
  
}



