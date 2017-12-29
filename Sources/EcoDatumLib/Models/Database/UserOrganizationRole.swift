import FluentProvider
import Vapor

final class UserOrganizationRole: EquatableModel {
  
  let storage = Storage()

  let userId: Identifier
  
  let organizationId: Identifier
  
  let roleId: Identifier
  
  struct Keys {
    static let id = "id"
    static let userId = User.foreignIdKey
    static let organizationId = Organization.foreignIdKey
    static let roleId = Role.foreignIdKey
  }
 
  init(userId: Identifier,
       organizationId: Identifier,
       roleId: Identifier) {
    self.userId = userId
    self.organizationId = organizationId
    self.roleId = roleId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    userId = try row.get(Keys.userId)
    organizationId = try row.get(Keys.organizationId)
    roleId = try row.get(Keys.roleId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.userId, userId)
    try row.set(Keys.organizationId, organizationId)
    try row.set(Keys.roleId, roleId)
    return row
  }

}

// MARK: Preparation

extension UserOrganizationRole: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.int(
        Keys.userId,
        optional: false,
        unique: false)
      builder.int(
        Keys.organizationId,
        optional: false,
        unique: false)
      builder.int(
        Keys.roleId,
        optional: false,
        unique: false)
    }
    try database.index(
      [
        Keys.userId,
        Keys.organizationId
      ],
      for: self)
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

// MARK: Relations

extension UserOrganizationRole {
  
  var user: Parent<UserOrganizationRole, User> {
    return parent(id: userId)
  }
  
  var organization: Parent<UserOrganizationRole, Organization> {
    return parent(id: organizationId)
  }
  
  var role: Parent<UserOrganizationRole, Role> {
    return parent(id: roleId)
  }
  
}

// MARK: TIMESTAMP

extension UserOrganizationRole: Timestampable { }





