import HTTP
import Vapor

extension Request {
  
  func assertJson() throws -> JSON {
    guard let json = json else {
      throw Abort(.badRequest, reason: "Invalid type. Expecting JSON.")
    }
    return json
  }
  
  func user() throws -> User {
    return try auth.assertAuthenticated()
  }
  
  func checkUserIsAdmin() throws -> Bool {
    return try user().isAdmin
  }
  
  func assertUserIsAdmin() throws {
    if try !checkUserIsAdmin() {
      throw Abort(.unauthorized)
    }
  }
  
  func checktRequestUserIsUser(_ user: User) throws -> Bool {
    return try self.user().id == user.id
  }
  
  func assertRequestUserIsUser(_ user: User) throws {
    if try !checktRequestUserIsUser(user) {
      throw Abort(.unauthorized)
    }
  }
  
  func checkUserOwnsOrganization(_ organization: Organization) throws -> Bool {
    return try user().id == organization.userId
  }
  
  func assertUserOwnsOrganization(_ organization: Organization) throws {
    if try !checkUserOwnsOrganization(organization) {
      throw Abort(.unauthorized)
    }
  }
  
}
