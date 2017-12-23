import Vapor
import FluentProvider
import HTTP

final class Organization: Model {
  
  let storage = Storage()
  
  // The name of the organization
  var name: String
  
  // The unique alphanumeric code assigned to the organization
  let code: String
  
  struct Keys {
    static let id = "id"
    static let name = "name"
    static let code = "code"
  }
  
  init(name: String,
       code: String) {
    self.name = name
    self.code = code
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    name = try row.get(Keys.name)
    code = try row.get(Keys.code)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.name, name)
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
        unique: false)
      builder.string(
        Keys.code,
        length: 6,
        optional: false,
        unique: true)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

// MARK: JSON

extension Organization: JSONConvertible {
  
  convenience init(json: JSON) throws {
    self.init(name: try json.get(Keys.name),
              code: try json.get(Keys.code))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.name, name)
    try json.set(Keys.code, code)
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


