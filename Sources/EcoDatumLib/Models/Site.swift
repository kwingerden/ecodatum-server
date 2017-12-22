import FluentProvider
import Foundation
import Vapor

final class Site: Model {
  
  let storage = Storage()
  
  let name: String
  
  let description: String?
  
  let userId: Identifier
  
  let locationId: Identifier
  
  struct Keys {
    static let id = "id"
    static let name = "name"
    static let description = "description"
    static let userId = User.foreignIdKey
    static let locationId = Location.foreignIdKey
  }
  
  init(name: String,
       description: String? = nil,
       userId: Identifier,
       locationId: Identifier) {
    self.name = name
    self.description = description
    self.userId = userId
    self.locationId = locationId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    name = try row.get(Keys.name)
    description = try row.get(Keys.description)
    userId = try row.get(Keys.userId)
    locationId = try row.get(Keys.locationId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.name, name)
    try row.set(Keys.description, description)
    try row.set(Keys.userId, userId)
    try row.set(Keys.locationId, locationId)
    return row
  }

}

// MARK: Preparation

extension Site: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.string(
        Keys.name,
        length: 250,
        optional: false,
        unique: true)
      builder.string(
        Keys.description,
        length: 500,
        optional: true,
        unique: false)
      builder.foreignId(
        for: User.self,
        optional: false,
        unique: false)
      builder.foreignId(
        for: Location.self,
        optional: false,
        unique: false)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

// MARK: Relations

extension Site {
  
  var user: Parent<Site, User> {
    return parent(id: userId)
  }
  
  var location: Parent<Site, Location> {
    return parent(id: locationId)
  }
  
}

// MARK: JSONRepresentable

extension Site: JSONConvertible {
  
  convenience init(json: JSON) throws {
    self.init(name: try json.get(Keys.name),
              description: try json.get(Keys.description),
              userId: try json.get(Keys.userId),
              locationId: try json.get(Keys.locationId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.name, name)
    try json.set(Keys.description, description)
    try json.set(Keys.userId, userId)
    try json.set(Keys.locationId, locationId)
    return json
  }
  
}

// MARK: ResponseRepresentable

extension Site: ResponseRepresentable { }

// MARK: Timestampable

extension Site: Timestampable { }

// MARK: SoftDeletable

extension Site: SoftDeletable { }




