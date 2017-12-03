import Vapor
import FluentProvider
import HTTP

final class Organization: Model {
  
  let storage = Storage()
  
  // The name of the organization
  var name: String
  
  // The unique alphanumeric code assigned to the organization
  let code: String
  
  // The identifier of the user to which this organization belongs
  let userId: Identifier
  
  struct Keys {
    static let id = "id"
    static let name = "name"
    static let code = "code"
    static let userId = User.foreignIdKey
  }
  
  init(name: String,
       code: String,
       userId: Identifier) {
    self.name = name
    self.code = code
    self.userId = userId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    name = try row.get(Keys.name)
    code = try row.get(Keys.code)
    userId = try row.get(Keys.userId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.name, name)
    try row.set(Keys.code, code)
    try row.set(Keys.userId, userId)
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
        Keys.name,
        length: 255,
        optional: false,
        unique: false)
      builder.char(
        Keys.code,
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

extension Organization: JSONRepresentable {
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.name, name)
    try json.set(Keys.code, code)
    try json.set(Keys.userId, userId)
    return json
  }
  
}

// MARK: HTTP

extension Organization: ResponseRepresentable { }

// MARK: TIMESTAMP

extension Organization: Timestampable { }

// MARK: UPDATE

extension Organization: Updateable {
  
  public static var updateableKeys: [UpdateableKey<Organization>] {
    return [
      UpdateableKey(Organization.Keys.name, String.self) {
        organization, name in
        organization.name = name
      }
    ]
  }
  
}

// MARK: DELETE

extension Organization: SoftDeletable { }

