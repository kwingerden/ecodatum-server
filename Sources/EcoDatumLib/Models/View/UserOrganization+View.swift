import Foundation
import Vapor

extension UserOrganizationRole: JSONConvertible {

  struct Json {
    static let id = Keys.id
    static let userId = "userId"
    static let organizationId = "organizationId"
    static let roleId = "roleId"
  }
  
  convenience init(json: JSON) throws {
    self.init(userId: try json.get(Json.userId),
              organizationId: try json.get(Json.organizationId),
              roleId: try json.get(Json.roleId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.userId, userId)
    try json.set(Json.organizationId, organizationId)
    try json.set(Json.roleId, roleId)
    return json
  }
  
}

extension UserOrganizationRole: ResponseRepresentable { }
