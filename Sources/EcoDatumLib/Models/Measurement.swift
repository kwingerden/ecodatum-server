import FluentProvider
import Foundation
import Vapor

final class Measurement: Model {
  
  let storage = Storage()
  
  let value: Double
  
  let abioticFactorId: Identifier
  
  let measurementUnitId: Identifier
  
  let surveyId: Identifier
  
  struct Keys {
    static let id = "id"
    static let value = "value"
    static let abioticFactorId = AbioticFactor.foreignIdKey
    static let measurementUnitId = MeasurementUnit.foreignIdKey
    static let surveyId = Survey.foreignIdKey
  }
  
  init(value: Double,
       abioticFactorId: Identifier,
       measurementUnitId: Identifier,
       surveyId: Identifier) {
    self.value = value
    self.abioticFactorId = abioticFactorId
    self.measurementUnitId = measurementUnitId
    self.surveyId = surveyId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    value = try row.get(Keys.value)
    abioticFactorId = try row.get(Keys.abioticFactorId)
    measurementUnitId = try row.get(Keys.measurementUnitId)
    surveyId = try row.get(Keys.surveyId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.value, value)
    try row.set(Keys.abioticFactorId, abioticFactorId)
    try row.set(Keys.measurementUnitId, measurementUnitId)
    try row.set(Keys.surveyId, surveyId)
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
        for: AbioticFactor.self,
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
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

// MARK: Relations

extension Measurement {
  
  var abioticFactor: Parent<Measurement, AbioticFactor> {
    return parent(id: abioticFactorId)
  }
  
  var measurementUnit: Parent<Measurement, MeasurementUnit> {
    return parent(id: measurementUnitId)
  }
  
  var survey: Parent<Measurement, Survey> {
    return parent(id: surveyId)
  }
  
}

// MARK: JSONConvertible

extension Measurement: JSONConvertible {
  
  convenience init(json: JSON) throws {
    self.init(value: try json.get(Keys.value),
              abioticFactorId: try json.get(Keys.abioticFactorId),
              measurementUnitId: try json.get(Keys.measurementUnitId),
              surveyId: try json.get(Keys.surveyId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.value, value)
    try json.set(Keys.abioticFactorId, abioticFactorId)
    try json.set(Keys.measurementUnitId, measurementUnitId)
    try json.set(Keys.surveyId, surveyId)
    return json
  }
  
}

// MARK: ResponseRepresentable

extension Measurement: ResponseRepresentable { }

// MARK: Timestampable

extension Measurement: Timestampable { }






