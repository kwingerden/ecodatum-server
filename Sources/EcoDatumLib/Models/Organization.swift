import Vapor
import FluentProvider
import HTTP

final class Organization: Model {
  
  static let CODE_LENGTH = 6
  
  let storage = Storage()
  
  // The name of the organization
  var name: String
  
  var description: String?

  // The unique alphanumeric code assigned to the organization
  let code: String
  
  struct Keys {
    static let id = "id"
    static let name = "name"
    static let description = "description"
    static let code = "code"
  }
  
  init(name: String,
       description: String? = nil,
       code: String) {
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
      builder.string(
        Keys.code,
        length: CODE_LENGTH,
        optional: false,
        unique: true)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

// MARK: UPDATE

extension Organization: Updateable {
  
  public static var updateableKeys: [UpdateableKey<Organization>] {
    return [
      UpdateableKey(Organization.Keys.name, String.self) {
        organization, name in
        organization.name = name
      },
      UpdateableKey(Organization.Keys.description, String.self) {
        organization, description in
        organization.description = description
      }
    ]
  }
  
}

// MARK: Relations

extension Organization {
  
  var userOrganizationRole: Parent<Organization, UserOrganizationRole> {
    return parent(id: id)
  }

  var sites: Children<Organization, Site> {
    return children()
  }

}

// MARK: JSON

extension Organization: JSONConvertible {
  
  convenience init(json: JSON) throws {
    self.init(name: try json.get(Keys.name),
              description: try json.get(Keys.description),
              code: try json.get(Keys.code))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.name, name)
    try json.set(Keys.description, description)
    try json.set(Keys.code, code)
    return json
  }
  
}

// MARK: HTTP

extension Organization: ResponseRepresentable { }

// MARK: TIMESTAMP

extension Organization: Timestampable { }

