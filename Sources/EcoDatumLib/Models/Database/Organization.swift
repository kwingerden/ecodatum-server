import FluentProvider
import Vapor

final class Organization: EquatableModel {
  
  static let CODE_LENGTH = 6
  
  let storage = Storage()
  
  // The name of the organization
  var name: String
  
  var description: String?

  // The unique alphanumeric code assigned to the organization
  var code: String?
  
  struct Keys {
    static let id = "id"
    static let name = "name"
    static let description = "description"
    static let code = "code"
  }
  
  init(name: String,
       description: String? = nil,
       code: String? = nil) {
    self.name = name
    self.description = description
    self.code = code
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    name = try row.get(Keys.name)
    description = try row.get(Keys.description)
    code = try row.get(Keys.code)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.name, name)
    try row.set(Keys.description, description)
    try row.set(Keys.code, code)
    return row
  }
}

// MARK: Preparation

extension Organization: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.string(
        Keys.name,
        length: 255,
        optional: false,
        unique: true)
      builder.string(
        Keys.description,
        length: 1024,
        optional: true,
        unique: false)
      builder.custom(
        Keys.code,
        type: "CHARACTER(\(CODE_LENGTH))",
        optional: false,
        unique: true)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

// MARK: Relations

extension Organization {
  
  var userOrganizationRoles: Children<Organization, UserOrganizationRole> {
    return children()
  }

  var sites: Children<Organization, Site> {
    return children()
  }

}

// MARK: TIMESTAMP

extension Organization: Timestampable { }

