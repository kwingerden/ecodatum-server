import FluentProvider
import Foundation
import HTTP
import Vapor

final class Image: Model {
  
  let storage = Storage()
  
  let base64Encoded: String
  
  let imageTypeId: Identifier
  
  let surveyId: Identifier
  
  struct Keys {
    static let id = "id"
    static let base64Encoded = "base64_encoded"
    static let imageTypeId = ImageType.foreignIdKey
    static let surveyId = Survey.foreignIdKey
  }
  
  init(base64Encoded: String,
       imageTypeId: Identifier,
       surveyId: Identifier) {
    self.base64Encoded = base64Encoded
    self.imageTypeId = imageTypeId
    self.surveyId = surveyId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    base64Encoded = try row.get(Keys.base64Encoded)
    imageTypeId = try row.get(Keys.imageTypeId)
    surveyId = try row.get(Keys.surveyId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.base64Encoded, base64Encoded)
    try row.set(Keys.imageTypeId, imageTypeId)
    try row.set(Keys.surveyId, surveyId)
    return row
  }
  
}

// MARK: Preparation

extension Image: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.custom(
        Keys.base64Encoded,
        type: "TEXT",
        optional: false,
        unique: false)
      builder.foreignId(
        for: ImageType.self,
        optional: false,
        unique: false)
      builder.foreignId(
        for: Survey.self,
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
  
  var imageType: Parent<Image, ImageType> {
    return parent(id: imageTypeId)
  }
  
  var survey: Parent<Image, Survey> {
    return parent(id: surveyId)
  }
  
}

// MARK: JSONConvertible

extension Image: JSONConvertible {
  
  convenience init(json: JSON) throws {
    self.init(base64Encoded: try json.get(Keys.base64Encoded),
              imageTypeId: try json.get(Keys.imageTypeId),
              surveyId: try json.get(Keys.surveyId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.base64Encoded, base64Encoded)
    try json.set(Keys.imageTypeId, imageTypeId)
    try json.set(Keys.surveyId, surveyId)
    return json
  }
  
}

// MARK: ResponseRepresentable

extension Image: ResponseRepresentable { }

// MARK: Timestampable

extension Image: Timestampable { }



