import Vapor
import FluentProvider
import HTTP

final class Role: Model {
  
  enum RoleType: Int {
    case ADMINISTRATOR = 1
    case MEMBER = 2
  }
  
  let storage = Storage()
  
  let roleId: Int
  
  let roleType: RoleType
  
  struct Keys {
    static let id = "id"
    static let roleId = "role_id"
    static let roleType = "role_type"
  }
  
  init(roleId: Int,
       roleType: RoleType) {
    self.roleId = roleId
    self.roleType = roleType
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    roleId = try row.get(Keys.roleId)
    guard let roleType = RoleType(rawValue: try row.get(Keys.roleType)) else {
      throw Abort(.badRequest)
    }
    self.roleType = roleType
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.roleId, roleId)
    try row.set(Keys.roleType, roleType.rawValue)
    return row
  }
}

// MARK: Preparation

extension Role: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.int(
        Keys.roleId,
        optional: false,
        unique: true)
      builder.int(
        Keys.roleType,
        optional: false,
        unique: false)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

// MARK: JSON

extension Role: JSONConvertible {
  
  convenience init(json: JSON) throws {
    self.init(roleId: try json.get(Keys.roleId),
              roleType: try json.get(Keys.roleType))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.roleId, roleId)
    try json.set(Keys.roleType, roleType.rawValue)
    return json
  }
  
}

// MARK: HTTP

extension Role: ResponseRepresentable { }

// MARK: TIMESTAMP

extension Role: Timestampable { }



