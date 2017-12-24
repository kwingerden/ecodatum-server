import FluentProvider
import Foundation
import Vapor

final class Survey: Model {
  
  let storage = Storage()

  let date: Date
  
  let siteId: Identifier

  let userId: Identifier
 
  struct Keys {
    static let id = "id"
    static let date = "date"
    static let siteId = Site.foreignIdKey
    static let userId = User.foreignIdKey
  }
  
  init(date: Date,
       siteId: Identifier,
       userId: Identifier) {
    self.date = date
    self.siteId = siteId
    self.userId = userId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    date = try row.get(Keys.date)
    siteId = try row.get(Keys.siteId)
    userId = try row.get(Keys.userId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.date, date)
    try row.set(Keys.siteId, siteId)
    try row.set(Keys.userId, userId)
    return row
  }
  
}

// MARK: Preparation

extension Survey: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.date(
        Keys.date,
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

extension Survey {
  
  var user: Parent<Survey,User> {
    return parent(id: userId)
  }

  var site: Parent<Survey, Site> {
    return parent(id: siteId)
  }
  
  var measurements: Children<Survey, Measurement> {
    return children()
  }

  var notes: Children<Survey, Note> {
    return children()
  }

  var images: Children<Survey, Image> {
    return children()
  }

}

// MARK: JSONConvertible

extension Survey: JSONConvertible {
  
  convenience init(json: JSON) throws {
    self.init(date: try json.get(Keys.date),
              siteId: try json.get(Keys.siteId),
              userId: try json.get(Keys.userId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.date, date)
    try json.set(Keys.siteId, siteId)
    try json.set(Keys.userId, userId)
    return json
  }
  
}

// MARK: ResponseRepresentable

extension Survey: ResponseRepresentable { }

// MARK: Timestampable

extension Survey: Timestampable { }





