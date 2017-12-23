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
  
  func checkRootUser() throws -> Bool {
    return try user().id?.int == Constants.ROOT_USER_ID
  }
  
  func assertRootUser() throws {
    if try !checkRootUser() {
      throw Abort(.unauthorized)
    }
  }
  
  func checktUserRequest(_ user: User) throws -> Bool {
    return try self.user().id == user.id
  }
  
  func assertUserRequest(_ user: User) throws {
    if try !checktUserRequest(user) {
      throw Abort(.unauthorized)
    }
  }
  
  func checkUserOwnsOrganization(_ organization: Organization) throws -> Bool {
    //return try user().id == organization.userId
    // TODO: need to fix!
    return true
  }
  
  func assertUserOwnsOrganization(_ organization: Organization) throws {
    if try !checkUserOwnsOrganization(organization) {
      throw Abort(.unauthorized)
    }
  }
  
  func checkUserOwnsImage(_ image: Image) throws -> Bool {
    return true
    //return try user().id == image.userId
  }
  
  func assertUserOwnsImage(_ image: Image) throws {
    if try !checkUserOwnsImage(image) {
      throw Abort(.unauthorized)
    }
  }
  
}
