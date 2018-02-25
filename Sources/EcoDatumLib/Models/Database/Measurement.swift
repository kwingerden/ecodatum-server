import FluentProvider
import Foundation
import Vapor

final class Measurement: EquatableModel {
  
  let storage = Storage()
  
  var value: Double

  var primaryAbioticFactorId: Identifier

  var secondaryAbioticFactorId: Identifier

  var measurementUnitId: Identifier

  let surveyId: Identifier
  
  let userId: Identifier
  
  struct Keys {
    static let id = "id"
    static let value = "value"
    static let primaryAbioticFactorId = PrimaryAbioticFactor.foreignIdKey
    static let secondaryAbioticFactorId = SecondaryAbioticFactor.foreignIdKey
    static let measurementUnitId = MeasurementUnit.foreignIdKey
    static let surveyId = Survey.foreignIdKey
    static let userId = User.foreignIdKey
  }
  
  init(value: Double,
       primaryAbioticFactorId: Identifier,
       secondaryAbioticFactorId: Identifier,
       measurementUnitId: Identifier,
       surveyId: Identifier,
       userId: Identifier) {
    self.value = value
    self.primaryAbioticFactorId = primaryAbioticFactorId
    self.secondaryAbioticFactorId = secondaryAbioticFactorId
    self.measurementUnitId = measurementUnitId
    self.surveyId = surveyId
    self.userId = userId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    value = try row.get(Keys.value)
    primaryAbioticFactorId = try row.get(Keys.primaryAbioticFactorId)
    secondaryAbioticFactorId = try row.get(Keys.secondaryAbioticFactorId)
    measurementUnitId = try row.get(Keys.measurementUnitId)
    surveyId = try row.get(Keys.surveyId)
    userId = try row.get(Keys.userId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.value, value)
    try row.set(Keys.primaryAbioticFactorId, primaryAbioticFactorId)
    try row.set(Keys.secondaryAbioticFactorId, secondaryAbioticFactorId)
    try row.set(Keys.measurementUnitId, measurementUnitId)
    try row.set(Keys.surveyId, surveyId)
    try row.set(Keys.userId, userId)
    return row
  }
  
}

// MARK: Preparation

extension Measurement: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.double(
        Keys.value,
        optional: false,
        unique: false)
      builder.foreignId(
        for: PrimaryAbioticFactor.self,
        optional: false,
        unique: false)
      builder.foreignId(
        for: SecondaryAbioticFactor.self,
        optional: false,
        unique: false)
      builder.foreignId(
        for: MeasurementUnit.self,
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

extension Measurement {
  
  var primaryAbioticFactor: Parent<Measurement, PrimaryAbioticFactor> {
    return parent(id: primaryAbioticFactorId)
  }

  var secondaryAbioticFactor: Parent<Measurement, SecondaryAbioticFactor> {
    return parent(id: primaryAbioticFactorId)
  }
  
  var measurementUnit: Parent<Measurement, MeasurementUnit> {
    return parent(id: measurementUnitId)
  }
  
  var survey: Parent<Measurement, Survey> {
    return parent(id: surveyId)
  }
  
  var user: Parent<Measurement, User> {
    return parent(id: userId)
  }
  
}

// MARK: Timestampable

extension Measurement: Timestampable { }


