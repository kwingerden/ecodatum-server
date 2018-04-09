import FluentProvider
import Foundation
import Vapor

final class QualitativeObservationFactor: EquatableModel {

  let storage = Storage()

  var ecosystemFactorId: Identifier

  var qualitativeObservationTypeId: Identifier

  var media: Blob

  var mediaTypeId: Identifier

  var description: String?

  let siteId: Identifier

  let userId: Identifier

  struct Keys {
    static let id = "id"
    static let ecosystemFactorId = EcosystemFactor.foreignIdKey
    static let qualitativeObservationTypeId = QualitativeObservationType.foreignIdKey
    static let media = "media"
    static let mediaTypeId = MediaType.foreignIdKey
    static let description = "description"
    static let siteId = Site.foreignIdKey
    static let userId = User.foreignIdKey
  }

  init(ecosystemFactorId: Identifier,
       qualitativeObservationTypeId: Identifier,
       media: Blob,
       mediaTypeId: Identifier,
       description: String? = nil,
       siteId: Identifier,
       userId: Identifier) {
    self.ecosystemFactorId = ecosystemFactorId
    self.qualitativeObservationTypeId = qualitativeObservationTypeId
    self.media = media
    self.mediaTypeId = mediaTypeId
    self.description = description
    self.siteId = siteId
    self.userId = userId
  }

  // MARK: Row

  init(row: Row) throws {
    ecosystemFactorId = try row.get(Keys.ecosystemFactorId)
    qualitativeObservationTypeId = try row.get(Keys.qualitativeObservationTypeId)
    media = try row.get(Keys.media)
    mediaTypeId = try row.get(Keys.mediaTypeId)
    description = try row.get(Keys.description)
    siteId = try row.get(Keys.siteId)
    userId = try row.get(Keys.userId)
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.ecosystemFactorId, ecosystemFactorId)
    try row.set(Keys.qualitativeObservationTypeId, qualitativeObservationTypeId)
    try row.set(Keys.media, media)
    try row.set(Keys.mediaTypeId, mediaTypeId)
    try row.set(Keys.description, description)
    try row.set(Keys.siteId, siteId)
    try row.set(Keys.userId, userId)
    return row
  }

}

// MARK: Preparation

extension QualitativeObservationFactor: Preparation {

  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.foreignId(
        for: EcosystemFactor.self,
        optional: false,
        unique: false)
      builder.foreignId(
        for: QualitativeObservationType.self,
        optional: false,
        unique: false)
      builder.bytes(
        Keys.media,
        optional: false,
        unique: false)
      builder.foreignId(
        for: MediaType.self,
        optional: false,
        unique: false)
      builder.bytes(
        Keys.description,
        optional: true,
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

extension QualitativeObservationFactor {

  var user: Parent<QualitativeObservationFactor, User> {
    return parent(id: userId)
  }

  var site: Parent<QualitativeObservationFactor, Site> {
    return parent(id: siteId)
  }

  func ecosystemFactor() throws -> EcosystemFactor? {
    return try EcosystemFactor.find(ecosystemFactorId)
  }

  func qualitativeObservationType() throws -> QualitativeObservationType? {
    return try QualitativeObservationType.find(qualitativeObservationTypeId)
  }

  func mediaType() throws -> MediaType? {
    return try MediaType.find(mediaTypeId)
  }

}

// MARK: Timestampable

extension QualitativeObservationFactor: Timestampable { }


