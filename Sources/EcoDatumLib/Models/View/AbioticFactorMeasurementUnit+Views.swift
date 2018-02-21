import Foundation
import Vapor

extension AbioticFactorMeasurementUnit: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let primaryAbioticFactor = "primaryAbioticFactor"
    static let secondaryAbioticFactor = "secondaryAbioticFactor"
    static let measurementUnit = "measurementUnit"
  }
  
  convenience init(json: JSON) throws {

    let primaryAbioticFactor = try PrimaryAbioticFactor(
      json: try json.get(Json.primaryAbioticFactor))
    let secondaryAbioticFactor = try SecondaryAbioticFactor(
      json: try json.get(Json.secondaryAbioticFactor))
    let measurementUnit = try MeasurementUnit(
      json: try json.get(Json.measurementUnit))

    guard let primaryAbioticFactorId = primaryAbioticFactor.id,
          let secondaryAbioticFactorId = secondaryAbioticFactor.id,
          let measurementUnitId = measurementUnit.id else {
      throw Abort(.internalServerError)
    }

    self.init(
      primaryAbioticFactorId: primaryAbioticFactorId,
      secondaryAbioticFactorId: secondaryAbioticFactorId,
      measurementUnitId: measurementUnitId)

  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.primaryAbioticFactor, primaryAbioticFactor)
    try json.set(Json.secondaryAbioticFactor, secondaryAbioticFactor)
    try json.set(Json.measurementUnit, measurementUnit)
    return json
  }
  
}

extension AbioticFactorMeasurementUnit: ResponseRepresentable { }

