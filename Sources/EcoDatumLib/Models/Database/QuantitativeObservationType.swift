import FluentProvider
import Foundation
import Vapor

final class QuantitativeObservationType: EquatableModel {

  enum Name: String {

    case CarbonDioxide
    case Conductivity

    case DissolvedOxygen

    case Light

    case Moisture

    case Nitrate
    case Nitrogen

    case Odor

    case PAR
    case pH
    case Phosphate
    case Phosphorous
    case Potassium

    case RelativeHumidity

    case Temperature
    case Texture
    case Turbidity

    case UVB

    case Velocity

    static let all: [Name] = [
      .CarbonDioxide,
      .Conductivity,

      .DissolvedOxygen,

      .Light,

      .Moisture,

      .Nitrate,
      .Nitrogen,

      .Odor,

      .PAR,
      .pH,
      .Phosphate,
      .Phosphorous,
      .Potassium,

      .RelativeHumidity,

      .Temperature,
      .Texture,
      .Turbidity,

      .UVB,

      .Velocity
    ]

  }

  let storage = Storage()

  let name: Name

  struct Keys {
    static let id = "id"
    static let name = "name"
  }

  init(name: Name) {
    self.name = name
  }

  // MARK: Row

  init(row: Row) throws {
    guard let name = Name(rawValue: try row.get(Keys.name)) else {
      throw Abort(.internalServerError)
    }
    self.name = name
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.name, name.rawValue)
    return row
  }

}

// MARK: Preparation

extension QuantitativeObservationType: Preparation {

  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.string(
        Keys.name,
        optional: false,
        unique: true)
    }
  }

  static func revert(_ database: Database) throws {
    try database.delete(self)
  }

}




