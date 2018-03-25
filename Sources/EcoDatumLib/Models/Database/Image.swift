import Bits
import FluentProvider
import Foundation
import Vapor

final class Image: EquatableModel {
    
  let storage = Storage()
  
  var image: Blob?

  var description: String?
  
  var imageTypeId: Identifier
  
  let surveyId: Identifier

  let userId: Identifier

  struct Keys {
    static let id = "id"
    static let image = "image"
    static let description = "description"
    static let imageTypeId = ImageType.foreignIdKey
    static let surveyId = Survey.foreignIdKey
    static let userId = User.foreignIdKey
  }
  
  init(image: Blob? = nil,
       description: String? = nil,
       imageTypeId: Identifier,
       surveyId: Identifier,
       userId: Identifier) {
    self.image = image
    self.description = description
    self.imageTypeId = imageTypeId
    self.surveyId = surveyId
    self.userId = userId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    image = try row.get(Keys.image)
    description = try row.get(Keys.description)
    imageTypeId = try row.get(Keys.imageTypeId)
    surveyId = try row.get(Keys.surveyId)
    userId = try row.get(Keys.userId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.image, image)
    try row.set(Keys.description, description)
    try row.set(Keys.imageTypeId, imageTypeId)
    try row.set(Keys.surveyId, surveyId)
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
      builder.bytes(
        Keys.image,
        optional: false,
        unique: false)
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
  
  var imageType: Parent<Image, ImageType> {
    return parent(id: imageTypeId)
  }
  
  var survey: Parent<Image, Survey> {
    return parent(id: surveyId)
  }

  var user: Parent<Image, User> {
    return parent(id: userId)
  }
  
}

// MARK: Timestampable

extension Image: Timestampable { }



