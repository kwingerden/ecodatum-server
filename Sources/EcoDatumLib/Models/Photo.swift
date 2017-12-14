import FluentProvider
import Foundation
import HTTP
import Vapor

final class Photo: Model {
  
  let storage = Storage()
  
  let hash: String
  
  let photo: Data
  
  let userId: Identifier
  
  struct Keys {
    static let id = "id"
    static let hash = "hash"
    static let photo = "photo"
    static let userId = User.foreignIdKey
  }
  
  init(hash: String,
       photo: Data,
       userId: Identifier) {
    self.hash = hash
    self.photo = photo
    self.userId = userId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    hash = try row.get(Keys.hash)
    photo = try row.get(Keys.photo)
    userId = try row.get(Keys.userId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.hash, hash)
    try row.set(Keys.photo, photo)
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
      builder.varchar(
        Keys.hash,
        length: 255,
        optional: false,
        unique: true)
      builder.bytes(
        Keys.photo,
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

extension Photo: JSONRepresentable {
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.hash, hash)
    try json.set(Keys.photo, photo)
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


