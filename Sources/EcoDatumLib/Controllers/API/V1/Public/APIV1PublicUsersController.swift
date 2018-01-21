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
  
  // POST public/users
  func store(_ request: Request) throws -> ResponseRepresentable {
    
    guard let json = request.json,
      let organizationCode: String = try json.get("organizationCode"),
      !organizationCode.isEmpty,
      let email: String = try json.get("email"),
      !email.isEmpty,
      let password: String = try json.get("password"),
      !password.isEmpty else {
        throw Abort(.badRequest, reason: "Invalid JSON")
    }
    
    if password.count < Constants.MIN_PASSWORD_COUNT {
      throw Abort(
        .preconditionFailed,
        reason: "A minimum of \(Constants.MIN_PASSWORD_COUNT) characters are required for the password.")
    }
    
    guard let organization = try modelManager.findOrganization(byCode: organizationCode) else {
      throw Abort(
        .preconditionFailed,
        reason: "Unable to find organization with code: \(organizationCode)")
    }
    
    if let _ = try modelManager.findUser(byEmail: email) {
      throw Abort(
        .preconditionFailed,
        reason: "User already has an account: \(email)")
    }
    
    guard let user = try? modelManager.createUser(json: json) else {
      throw Abort(.internalServerError, reason: "Failed to create user: \(email)")
    }
    
    let role = try modelManager.getRole(name: .MEMBER)
    let _  = try modelManager.addUserToOrganization(
      user: user,
      organization: organization,
      role: role)
    
    return user
    
  }
  
  func makeResource() -> Resource<User> {
    return Resource(store: store)
  }
  
}



