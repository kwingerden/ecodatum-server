import FluentProvider
import Foundation
import HTTP
import Vapor

final class Image: Model {
  
  enum ImageType: Int {
    case png = 0
    case jpg = 1
  }
  
  let storage = Storage()
  
  let uuid: String
  
  let imageType: ImageType
  
  let userId: Identifier
  
  struct Keys {
    static let id = "id"
    static let base64Encoded = "base64_encoded"
    static let uuid = "uuid"
    static let imageType = "image_type"
    static let userId = User.foreignIdKey
  }
  
  init(uuid: String,
       imageType: ImageType,
       userId: Identifier) {
    self.uuid = uuid
    self.imageType = imageType
    self.userId = userId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    uuid = try row.get(Keys.uuid)
    guard let imageType = ImageType(rawValue: try row.get(Keys.imageType)) else {
      throw Abort(.badRequest)
    }
    self.imageType = imageType
    userId = try row.get(Keys.userId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.uuid, uuid)
    try row.set(Keys.imageType, imageType.rawValue)
    try row.set(Keys.userId, userId)
    return row
  }
  
}

// MARK: Preparation

extension Image: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.string(
        Keys.uuid,
        optional: false,
        unique: true)
      builder.int(
        Keys.imageType,
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

extension Image {
  
  var user: Parent<Image, User> {
    return parent(id: userId)
  }
  
}

// MARK: JSONRepresentable

extension Image: JSONConvertible {
  
  convenience init(json: JSON) throws {
    guard let imageType = ImageType(rawValue: try json.get(Keys.imageType)) else {
      throw Abort(.badRequest)
    }
    self.init(
      uuid: try json.get(Keys.uuid),
      imageType: imageType,
      userId: try json.get(Keys.userId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.uuid, uuid)
    try json.set(Keys.imageType, imageType.rawValue)
    try json.set(Keys.userId, userId)
    return json
  }
  
}

// MARK: ResponseRepresentable

extension Image: ResponseRepresentable { }

// MARK: Timestampable

extension Image: Timestampable { }



