import FluentProvider
import Vapor

final class AbioticFactorMeasurementUnit: EquatableModel {

  let storage = Storage()

  let primaryAbioticFactorId: Identifier

  let secondaryAbioticFactorId: Identifier

  let measurementUnitId: Identifier

  struct Keys {
    static let id = "id"
    static let primaryAbioticFactorId = PrimaryAbioticFactor.foreignIdKey
    static let secondaryAbioticFactorId = SecondaryAbioticFactor.foreignIdKey
    static let measurementUnitId = MeasurementUnit.foreignIdKey
  }

  init(primaryAbioticFactorId: Identifier,
       secondaryAbioticFactorId: Identifier,
       measurementUnitId: Identifier) {
    self.primaryAbioticFactorId = primaryAbioticFactorId
    self.secondaryAbioticFactorId = secondaryAbioticFactorId
    self.measurementUnitId = measurementUnitId
  }

  // MARK: Row

  init(row: Row) throws {
    primaryAbioticFactorId = try row.get(Keys.primaryAbioticFactorId)
    secondaryAbioticFactorId = try row.get(Keys.secondaryAbioticFactorId)
    measurementUnitId = try row.get(Keys.measurementUnitId)
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.primaryAbioticFactorId, primaryAbioticFactorId)
    try row.set(Keys.secondaryAbioticFactorId, secondaryAbioticFactorId)
    try row.set(Keys.measurementUnitId, measurementUnitId)
    return row
  }

}

// MARK: Preparation

extension AbioticFactorMeasurementUnit: Preparation {

  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.string(
        Keys.primaryAbioticFactorId,
        optional: false,
        unique: false)
      builder.string(
        Keys.secondaryAbioticFactorId,
        optional: false,
        unique: false)
      builder.string(
        Keys.measurementUnitId,
        optional: false,
        unique: false)
    }
    try database.index(
      [
        Keys.primaryAbioticFactorId,
        Keys.secondaryAbioticFactorId,
        Keys.measurementUnitId
      ],
      for: self)
  }

  static func revert(_ database: Database) throws {
    try database.delete(self)
  }

}

// MARK: Relations

extension AbioticFactorMeasurementUnit {

  var primaryAbioticFactor: Parent<AbioticFactorMeasurementUnit, PrimaryAbioticFactor> {
    return parent(id: primaryAbioticFactorId)
  }

  var secondaryAbioticFactor: Parent<AbioticFactorMeasurementUnit, SecondaryAbioticFactor> {
    return parent(id: secondaryAbioticFactorId)
  }

  var measurementUnit: Parent<AbioticFactorMeasurementUnit, MeasurementUnit> {
    return parent(id: measurementUnitId)
  }

}

// MARK: TIMESTAMP

extension AbioticFactorMeasurementUnit: Timestampable { }





