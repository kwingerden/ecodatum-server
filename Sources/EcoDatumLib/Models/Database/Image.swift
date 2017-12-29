import Bits
import FluentProvider
import Foundation
import Vapor

final class Image: EquatableModel {
  
  static let CODE_LENGTH = 10
  
  let storage = Storage()
  
  var image: Blob?
  
  let code: String

  var description: String?
  
  var imageTypeId: Identifier
  
  let surveyId: Identifier
  
  struct Keys {
    static let id = "id"
    static let image = "image"
    static let code = "code"
    static let description = "description"
    static let imageTypeId = ImageType.foreignIdKey
    static let surveyId = Survey.foreignIdKey
  }
  
  init(image: Blob? = nil,
       code: String,
       description: String? = nil,
       imageTypeId: Identifier,
       surveyId: Identifier) {
    self.image = image
    self.code = code
    self.description = description
    self.imageTypeId = imageTypeId
    self.surveyId = surveyId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    image = try row.get(Keys.image)
    code = try row.get(Keys.code)
    description = try row.get(Keys.description)
    imageTypeId = try row.get(Keys.imageTypeId)
    surveyId = try row.get(Keys.surveyId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.image, image)
    try row.set(Keys.code, code)
    try row.set(Keys.description, description)
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
      builder.bytes(
        Keys.image,
        optional: false,
        unique: false)
      builder.custom(
        Keys.code,
        type: "CHARACTER(\(CODE_LENGTH))",
        optional: false,
        unique: true)
      builder.string(
        Keys.description,
        length: 500,
        optional: true,
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

// MARK: Timestampable

extension Image: Timestampable { }



