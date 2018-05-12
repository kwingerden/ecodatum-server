import FluentProvider
import Foundation
import Vapor

final class EcoDatum: EquatableModel {

  let storage = Storage()

  var json: String

  let siteId: Identifier

  let userId: Identifier

  struct Keys {
    static let id = "id"
    static let json = "json"
    static let siteId = Site.foreignIdKey
    static let userId = User.foreignIdKey
  }

  init(json: String,
       siteId: Identifier,
       userId: Identifier) {
    self.json = json
    self.siteId = siteId
    self.userId = userId
  }

  // MARK: Row

  init(row: Row) throws {
    json = try row.get(Keys.json)
    siteId = try row.get(Keys.siteId)
    userId = try row.get(Keys.userId)
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.json, json)
    try row.set(Keys.siteId, siteId)
    try row.set(Keys.userId, userId)
    return row
  }

}

// MARK: Preparation

extension EcoDatum: Preparation {

  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.custom(
        Keys.json,
        type: "jsonb",
        optional: false,
        unique: false)
      builder.foreignId(
        for: Site.self,
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

extension EcoDatum {

  var user: Parent<EcoDatum, User> {
    return parent(id: userId)
  }

  var site: Parent<EcoDatum, Site> {
    return parent(id: siteId)
  }

}

// MARK: Timestampable

extension EcoDatum: Timestampable { }


