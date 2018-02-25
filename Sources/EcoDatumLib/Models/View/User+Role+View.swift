import AuthProvider
import Foundation
import Vapor

final class UserAndRole: JSONRepresentable {
  
  let user: User
  
  let role: Role
  
  struct Json {
    static let user = "user"
    static let role = "role"
  }
  
  init(user: User,
       role: Role) throws {
    self.user = user
    self.role = role
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.user, user)
    try json.set(Json.role, role)
    return json
  }
  
}

extension UserAndRole: ResponseRepresentable { }





