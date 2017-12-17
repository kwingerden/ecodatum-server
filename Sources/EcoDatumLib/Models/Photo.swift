import FluentProvider
import Foundation
import HTTP
import Vapor

final class Photo: Model {
  
  let storage = Storage()
  
  let base64: String
  
  let userId: Identifier
  
  struct Keys {
    static let id = "id"
    static let base64 = "base64"
    static let userId = User.foreignIdKey
  }
  
  init(base64: String,
       userId: Identifier) {
    self.base64 = base64
    self.userId = userId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    base64 = try row.get(Keys.base64)
    userId = try row.get(Keys.userId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.base64, base64)
    try row.set(Keys.userId, userId)
    return row
  }
}

// MARK: Preparation

extension Photo: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.longText(
        Keys.base64,
        optional: false,
        unique: false)
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

extension Photo {
  
  var user: Parent<Photo, User> {
    return parent(id: userId)
  }
  
}

// MARK: JSONRepresentable

extension Photo: JSONConvertible {
  
  convenience init(json: JSON) throws {
    self.init(base64: try json.get(Keys.base64),
              userId: try json.get(Keys.userId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.base64, base64)
    try json.set(Keys.userId, userId)
    return json
  }
  
}

// MARK: ResponseRepresentable

extension Photo: ResponseRepresentable { }

// MARK: Timestampable

extension Photo: Timestampable { }

// MARK: SoftDeletable

extension Photo: SoftDeletable { }


