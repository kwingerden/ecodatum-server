import FluentProvider
import Foundation
import Vapor

final class QuantitativeObservationFactor: EquatableModel {

  let storage = Storage()

  var ecosystemFactorId: Identifier

  var quantitativeObservationTypeId: Identifier

  var measurementValue: String

  var measurementUnitId: Identifier

  var description: Blob?

  let siteId: Identifier

  let userId: Identifier

  struct Keys {
    static let id = "id"
    static let ecosystemFactorId = EcosystemFactor.foreignIdKey
    static let quantitativeObservationTypeId = QuantitativeObservationType.foreignIdKey
    static let measurementValue = "measurement_value"
    static let measurementUnitId = MeasurementUnit.foreignIdKey
    static let description = "description"
    static let siteId = Site.foreignIdKey
    static let userId = User.foreignIdKey
  }

  init(ecosystemFactorId: Identifier,
       quantitativeObservationTypeId: Identifier,
       measurementValue: String,
       measurementUnitId: Identifier,
       description: Blob? = nil,
       siteId: Identifier,
       userId: Identifier) {
    self.ecosystemFactorId = ecosystemFactorId
    self.quantitativeObservationTypeId = quantitativeObservationTypeId
    self.measurementValue = measurementValue
    self.measurementUnitId = measurementUnitId
    self.description = description
    self.siteId = siteId
    self.userId = userId
  }

  // MARK: Row

  init(row: Row) throws {
    ecosystemFactorId = try row.get(Keys.ecosystemFactorId)
    quantitativeObservationTypeId = try row.get(Keys.quantitativeObservationTypeId)
    measurementValue = try row.get(Keys.measurementValue)
    measurementUnitId = try row.get(Keys.measurementUnitId)
    description = try row.get(Keys.description)
    siteId = try row.get(Keys.siteId)
    userId = try row.get(Keys.userId)
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.ecosystemFactorId, ecosystemFactorId)
    try row.set(Keys.quantitativeObservationTypeId, quantitativeObservationTypeId)
    try row.set(Keys.measurementValue, measurementValue)
    try row.set(Keys.measurementUnitId, measurementUnitId)
    try row.set(Keys.description, description)
    try row.set(Keys.siteId, siteId)
    try row.set(Keys.userId, userId)
    return row
  }

}

// MARK: Preparation

extension QuantitativeObservationFactor: Preparation {

  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.foreignId(
        for: EcosystemFactor.self,
        optional: false,
        unique: false)
      builder.foreignId(
        for: QuantitativeObservationType.self,
        optional: false,
        unique: false)
      builder.string(
        Keys.measurementValue,
        length: 100,
        optional: false,
        unique: false)
      builder.foreignId(
        for: MeasurementUnit.self,
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

extension QuantitativeObservationFactor {

  var user: Parent<QuantitativeObservationFactor, User> {
    return parent(id: userId)
  }

  var site: Parent<QuantitativeObservationFactor, Site> {
    return parent(id: siteId)
  }

  func ecosystemFactor() throws -> EcosystemFactor? {
    return try EcosystemFactor.find(ecosystemFactorId)
  }

  func quantitativeObservationType() throws -> QuantitativeObservationType? {
    return try QuantitativeObservationType.find(quantitativeObservationTypeId)
  }

  func measurementUnit() throws -> MeasurementUnit? {
    return try MeasurementUnit.find(measurementUnitId)
  }

}

// MARK: Timestampable

extension QuantitativeObservationFactor: Timestampable { }


