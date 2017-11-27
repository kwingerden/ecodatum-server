import Vapor
import FluentProvider
import HTTP

final class Organization: Model {
  
  let storage = Storage()
  
  // The name of the organization
  let name: String
  
  // The unique alphanumeric code assigned to the organization
  let code: String

  // The identifier of the user to which this organization belongs
  let userId: Identifier
  
  init(name: String, code: String, userId: Identifier) {
    self.name = name
    self.code = code
    self.userId = userId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    name = try row.get("name")
    code = try row.get("code")
    userId = try row.get(User.foreignIdKey)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set("name", name)
    try row.set("code", code)
    try row.set(User.foreignIdKey, userId)
    return row
  }
}

// MARK: Preparation

extension Organization: Preparation {

  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.varchar(
        "name",
        length: 255,
        optional: false,
        unique: false)
      builder.char(
        "code",
        length: 6,
        optional: false,
        unique: true)
      builder.foreignId(
        for: User.self,
        optional: false,
        unique: false)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

// MARK: Relations

extension Organization {

  var user: Parent<Organization, User> {
    return parent(id: userId)
  }
  
}

// MARK: JSON

extension Organization: JSONConvertible {
  
  convenience init(json: JSON) throws {
    // Organizations will not be fully created with JSON
    throw Abort(.methodNotAllowed)
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set("id", id)
    try json.set("name", name)
    try json.set("code", code)
    try json.set("userId", userId)
    return json
  }
}

// MARK: HTTP

extension Organization: ResponseRepresentable { }

// MARK: TIMESTAMP

extension Organization: Timestampable { }

// MARK: DELETE

extension Organization: SoftDeletable { }

